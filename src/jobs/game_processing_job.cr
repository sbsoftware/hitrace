class GameProcessingJob < RecurringBackgroundJob
  GAME_START_TIMEOUT = 30.seconds

  def run_iteration : Bool
    changed = false

    Game.where(processing_completed: false).find_each do |game|
      if !game.started?
        if game.game_players.all?(&.ready?)
          now = Time.utc
          # Shift to the next full second because decimal seconds are stripped by the DB currently.
          game.update(started_at: now.shift(nanoseconds: 1000000000 - now.nanosecond))
          changed = true
        elsif game.created_at < GAME_START_TIMEOUT.ago
          # Mark game as finished immediately.
          game.update(started_at: game.created_at)
          changed = true
        end

        refresh_game_views(game)
      end

      if game.finished?
        game_players = game.game_players.to_a
        if game_players.size == 2
          if winner = game.winner
            if entry = LeaderboardEntry.where(user_id: winner.user_id).first?
              entry.update(games_won: entry.games_won.value + 1)
            else
              LeaderboardEntry.create(user_id: winner.user_id, games_won: 1_i64)
            end
            changed = true
          end
        end

        if (room = game.room) && room.game_id == game.id
          room.reset!
          changed = true
        end

        game.update(processing_completed: true)
        changed = true

        refresh_game_views(game)
      end
    end

    changed
  end

  private def refresh_game_views(game : Game) : Nil
    game.game_players.each do |game_player|
      game_player.game_view.refresh!
    end
  end
end
