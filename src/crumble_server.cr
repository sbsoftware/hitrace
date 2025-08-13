require "./environment"

# Empty service worker for now
register_service_worker

web_manifest do
  name "Hitrace"
  short_name "Hitrace"
  description "Hit the glowing tiles faster than your opponent!"
  display :standalone
  background_color "rgba(2,7,13,1)"
  theme_color "white"

  icon PNGFile.register("logo_192.png", "assets/logo_192.png"), sizes: "192x192"

  # Mobile
  screenshot JPGFile.register("screenshot_game_mobile.jpg", "assets/screenshot_game_mobile.jpg"), label: "Game Grid", sizes: "1080x1946"
  screenshot JPGFile.register("screenshot_game_summary_mobile.jpg", "assets/screenshot_game_summary_mobile.jpg"), label: "Game Summary", sizes: "1080x1946"

  # Desktop
  screenshot PNGFile.register("screenshot_game_desktop.png", "assets/screenshot_game_desktop.png"), label: "Game Grid", sizes: "1919x1016", form_factor: :wide
  screenshot PNGFile.register("screenshot_game_summary_desktop.png", "assets/screenshot_game_summary_desktop.png"), label: "Game Summary", sizes: "1919x1016", form_factor: :wide
end

spawn do
  loop do
    WaitingPlayer.all.each do |waiting_player|
      if waiting_player.created_at < 20.seconds.ago
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
            room_player.destroy
          end
        end

        if room.room_players.empty?
          room.destroy
        end
      end

      next unless room.ready?

      game = Game.create(room_id: room.id)

      room.room_players.each do |room_player|
        GamePlayer.create(game_id: game.id, user_id: room_player.user_id)
      end

      room.game_id = game.id
      room.last_game_started_at = Time.utc
      room.save
    end

    Game.where(processing_completed: false).find_each do |game|
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
            if entry = LeaderboardEntry.where(user_id: winner.user_id).first?
              entry.update(games_won: entry.games_won.value + 1)
            else
              LeaderboardEntry.create(user_id: winner.user_id, games_won: 1_i64)
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
