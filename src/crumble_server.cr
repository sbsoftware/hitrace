require "./environment"

spawn do
  loop do
    WaitingPlayer.all.each do |waiting_player|
      if waiting_player.created_at < 10.seconds.ago
        waiting_player.destroy unless waiting_player.online?
      end
    end

    WaitingPlayer.all.to_a.each_slice(2) do |waiting_players|
      next unless waiting_players.size > 1

      GameService.create_game({waiting_players[0], waiting_players[1]})
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

    Game.where({"processing_completed" => false}).find_each do |game|
      if !game.started?
        if game.game_players.all?(&.ready?)
          now = Time.utc
          # Shift to the next full second because decimal seconds are stripped by the DB currently
          game.update(started_at: now.shift(nanoseconds: 1000000000 - now.nanosecond))
        elsif game.created_at < 30.seconds.ago
          # Mark game as finished immediately
          game.update(started_at: game.created_at)
        end

        game.game_players.each do |game_player|
          Crumble::Turbo::ModelTemplateRefreshService.notify(game_player.game_view)
        end
      end

      if game.finished?
        game_players = game.game_players.to_a
        if game.room_id.nil? && game_players.size == 2
          if winner = game.winner
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

        game.game_players.each do |game_player|
          Crumble::Turbo::ModelTemplateRefreshService.notify(game_player.game_view)
        end
      end
    end

    sleep 1.second
  end
end

Crumble::Server.start
