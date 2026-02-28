require "log"

class GameProcessingJob < Crumble::Jobs::Job
  GAME_START_TIMEOUT = 30.seconds
  params game_id : Int64

  def perform : Nil
    unless game = Game.where(id: game_id, processing_completed: false).first?
      logger.info { "Skipping game processing: game #{game_id} missing or already completed" }
      return
    end

    if !game.started?
      if game.game_players.all?(&.ready?)
        now = Time.utc
        # Shift to the next full second because decimal seconds are stripped by the DB currently.
        game.update(started_at: now.shift(nanoseconds: 1000000000 - now.nanosecond))
        logger.info { "Started game #{game.id.value}: all players ready" }
      elsif game.created_at < GAME_START_TIMEOUT.ago
        # Mark game as started at created_at so it can be completed immediately.
        game.update(started_at: game.created_at)
        logger.info { "Started game #{game.id.value} at created_at due to start timeout (#{GAME_START_TIMEOUT})" }
      else
        logger.info { "Game #{game.id.value} still waiting for ready players before timeout" }
      end
      refresh_game_views(game)
    else
      logger.info { "Game #{game.id.value} already started" }
    end

    unless game.finished?
      logger.info { "Game #{game.id.value} not finished yet" }
      if delay = remaining_duration(game)
        logger.info { "Scheduling follow-up game processing for game #{game.id.value} in #{delay}" }
        BackgroundJobs.enqueue_game_processing(game.id.value, delay: delay)
      end
      return
    end

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
      else
        logger.info { "Game #{game.id.value} finished without a winner" }
      end
    else
      logger.warn { "Game #{game.id.value} finished with unexpected player count #{game_players.size}" }
    end

    if (room = game.room) && room.game_id == game.id
      room.reset!
      logger.info { "Reset room #{room.id.value} after finished game #{game.id.value}" }
      if remaining_room_cleanup_delay = remaining_room_cleanup_delay(room)
        logger.info { "Scheduling follow-up room maintenance for room #{room.id.value} in #{remaining_room_cleanup_delay}" }
        BackgroundJobs.enqueue_room_maintenance(room.id.value, delay: remaining_room_cleanup_delay)
      else
        logger.info { "Scheduling immediate room maintenance for room #{room.id.value}" }
        BackgroundJobs.enqueue_room_maintenance(room.id.value)
      end
    else
      logger.info { "No room reset needed for game #{game.id.value}" }
    end

    game.update(processing_completed: true)
    logger.info { "Marked game #{game.id.value} processing as completed" }
    refresh_game_views(game)
  end

  private def refresh_game_views(game : Game) : Nil
    logger.info { "Refreshing game views for game #{game.id.value}" }
    game.game_players.each do |game_player|
      game_player.game_view.refresh!
    end
  end

  private def remaining_duration(game : Game) : Time::Span?
    return unless started_at = game.started_at.try(&.value)

    remaining_duration = Game::GAME_DURATION - (Time.utc - started_at)
    remaining_duration <= Time::Span.zero ? nil : remaining_duration
  end

  private def remaining_room_cleanup_delay(room : Room) : Time::Span?
    return unless last_game_started_at = room.last_game_started_at.try(&.value)

    remaining_delay = RoomMaintenanceJob::STALE_ROOM_AGE - (Time.utc - last_game_started_at)
    remaining_delay <= Time::Span.zero ? nil : remaining_delay
  end

  private def logger : Log
    Log.for(self.class.job_name)
  end
end
