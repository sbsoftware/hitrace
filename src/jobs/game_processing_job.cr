class GameProcessingJob < Crumble::Jobs::Job
  GAME_START_TIMEOUT = 30.seconds
  params game_id : Int64

  def perform : Nil
    unless game = Game.where(id: game_id, processing_completed: false).first?
      return
    end

    if !game.started?
      if game.game_players.all?(&.ready?)
        now = Time.utc
        # Shift to the next full second because decimal seconds are stripped by the DB currently.
        game.update(started_at: now.shift(nanoseconds: 1000000000 - now.nanosecond))
      elsif game.created_at < GAME_START_TIMEOUT.ago
        # Mark game as started at created_at so it can be completed immediately.
        game.update(started_at: game.created_at)
      end
      refresh_game_views(game)
    end

    unless game.finished?
      if delay = remaining_duration(game)
        BackgroundJobs.enqueue_game_processing(game.id.value, delay: delay)
      end
      return
    end

    game_players = game.game_players.to_a
    if game_players.size == 2
      if winner = game.winner
        if entry = LeaderboardEntry.where(user_id: winner.user_id).first?
          entry.update(games_won: entry.games_won.value + 1)
        else
          LeaderboardEntry.create(user_id: winner.user_id, games_won: 1_i64)
        end
      end
    end

    if (room = game.room) && room.game_id == game.id
      room.reset!
      if remaining_room_cleanup_delay = remaining_room_cleanup_delay(room)
        BackgroundJobs.enqueue_room_maintenance(room.id.value, delay: remaining_room_cleanup_delay)
      else
        BackgroundJobs.enqueue_room_maintenance(room.id.value)
      end
    end

    game.update(processing_completed: true)
    refresh_game_views(game)
  end

  private def refresh_game_views(game : Game) : Nil
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
end
