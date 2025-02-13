require "sqlite3"
require "orma"
require "crumble-turbo"
require "./ext/**"
require "./models/*"
require "./policies/**"
require "./actions/**"
require "./views/*"
require "./resources/*"

if ENV.fetch("ORMA_CONTINUOUS_MIGRATION", "").in?(["1", "true"])
  {% for orm_class in Orma::Record.all_subclasses %}
    {% if !orm_class.abstract? %}
      {{orm_class.id}}.continuous_migration!
    {% end %}
  {% end %}
end

# TODO: Remove again
Game.db.exec <<-SQL
UPDATE games SET processing_completed=1 WHERE processing_completed IS NULL;
SQL

spawn do
  loop do
    WaitingPlayer.all.each do |waiting_player|
      if waiting_player.created_at < 10.seconds.ago
        waiting_player.destroy unless waiting_player.online?
      end
    end

    WaitingPlayer.all.to_a.each_slice(2) do |waiting_players|
      next unless waiting_players.size > 1
      next unless waiting_players.all?(&.online?)
      next if waiting_players.any? do |waiting_player|
        GamePlayer.where({"session_id" => waiting_player.session_id}).any? do |game_player|
          !game_player.game.finished?
        end
      end

      new_game = Game.create

      waiting_players.each do |waiting_player|
        GamePlayer.create(game_id: new_game.id, session_id: waiting_player.session_id, player_name: waiting_player.player_name)
      end
    end

    Room.all.find_each do |room|
      unless (last_game_at = room.last_game_started_at) && last_game_at > 3.minutes.ago
        room.room_players.each do |room_player|
          if (last_check = room_player.last_connection_check_at) && last_check < 60.seconds.ago
            room_player.db.exec("DELETE FROM #{room_player.table_name} WHERE id=#{room_player.id}")
          end
        end

        if room.room_players.empty?
          room.db.exec("DELETE FROM #{room.table_name} WHERE id=#{room.id}")
        end
      end

      next unless room.ready?

      game = Game.create(room_id: room.id)

      room.room_players.each do |room_player|
        GamePlayer.create(game_id: game.id, session_id: room_player.session_id, player_name: room_player.player_name)
      end

      room.game_id = game.id
      room.last_game_started_at = Time.utc
      room.save
    end

    # TODO: Don't select completed games here?
    Game.where({"processing_completed" => false}).find_each do |game|
      if !game.started? && game.game_players.all?(&.online?)
        game.update(started_at: Time.utc)

        Crumble::Turbo::ModelTemplateRefreshService.notify(game.default_view)
      end

      if game.running? && game.hit_targets.count < 2
        if game_id = game.id
          HitTarget.create(game_id: game_id, pos_x: rand(1..game.size_x.value), pos_y: rand(1..game.size_y.value))
        end

        Crumble::Turbo::ModelTemplateRefreshService.notify(game.grid)
      end

      if game.finished?
        game_players = game.game_players.to_a
        if game.room_id.nil? && game_players.size == 2
          winner = game_players.max_by(&.score.value)

          unless game_players.select { |gp| gp.score == winner.score }.size > 1
            if entry = LeaderboardEntry.where({"session_id" => winner.session_id}).first?
              entry.update(games_won: entry.games_won.value + 1)
            else
              LeaderboardEntry.create(session_id: winner.session_id, player_name: winner.player_name, games_won: 1_i64)
            end
          end
        elsif (room = game.room) && room.game_id == game.id
          room.reset!
        end

        game.update(processing_completed: true)
      end
    end

    sleep 1.second
  end
end

Crumble::Server.start
