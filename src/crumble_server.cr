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

spawn do
  loop do
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
    Game.all.find_each do |game|
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

      if game.finished? && (room = game.room) && room.game_id == game.id
        room.reset!
      end
    end

    sleep 2.seconds
  end
end

Crumble::Server.start
