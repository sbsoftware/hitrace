class GameProcessingJob < RecurringBackgroundJob
  GAME_START_TIMEOUT = 30.seconds

  def run_iteration : Bool
    changed = false

    Game.where(processing_completed: false).find_each do |game|
      changed_for_game = false

      if !game.started?
        if game.game_players.all?(&.ready?)
          now = Time.utc
          # Shift to the next full second because decimal seconds are stripped by the DB currently.
          game.update(started_at: now.shift(nanoseconds: 1000000000 - now.nanosecond))
          changed = true
          changed_for_game = true
          logger.info { "Started game #{game.id.value}: all players ready" }
        elsif game.created_at < GAME_START_TIMEOUT.ago
          # Mark game as finished immediately.
          game.update(started_at: game.created_at)
          changed = true
          changed_for_game = true
          logger.info { "Started game #{game.id.value} at created_at due to start timeout (#{GAME_START_TIMEOUT})" }
        else
          logger.info { "Game #{game.id.value} still waiting for ready players before timeout" }
        end

        refresh_game_views(game)
      else
        logger.info { "Game #{game.id.value} already started" }
      end

      if game.finished?
        game_players = game.game_players.to_a
        if game_players.size == 2
          if winner = game.winner
            if entry = LeaderboardEntry.where(user_id: winner.user_id).first?
              entry.update(games_won: entry.games_won.value + 1)
              logger.info { "Incremented leaderboard entry #{entry.id.value} for winner user #{winner.user_id.value}" }
            else
              LeaderboardEntry.create(user_id: winner.user_id, games_won: 1_i64)
              logger.info { "Created leaderboard entry for winner user #{winner.user_id.value}" }
            end
            changed = true
            changed_for_game = true
          else
            logger.info { "Game #{game.id.value} finished without a winner" }
          end
        else
          logger.warn { "Game #{game.id.value} finished with unexpected player count #{game_players.size}" }
        end

        if (room = game.room) && room.game_id == game.id
          room.reset!
          changed = true
          changed_for_game = true
          logger.info { "Reset room #{room.id.value} after finished game #{game.id.value}" }
        else
          logger.info { "No room reset needed for game #{game.id.value}" }
        end

        game.update(processing_completed: true)
        changed = true
        changed_for_game = true
        logger.info { "Marked game #{game.id.value} processing as completed" }

        refresh_game_views(game)
      else
        logger.info { "Game #{game.id.value} not finished yet" }
      end

      logger.info { "Game #{game.id.value} iteration resulted in no state change" } unless changed_for_game
    end

    logger.info { "Game processing iteration made no changes" } unless changed
    changed
  end

  private def refresh_game_views(game : Game) : Nil
    logger.info { "Refreshing game views for game #{game.id.value}" }
    game.game_players.each do |game_player|
      game_player.game_view.refresh!
    end
  end
end
