module BackgroundJobs
  DISABLE_DELAYED_ENQUEUE_ENV_KEY = "HIT_DISABLE_DELAYED_JOB_ENQUEUE"

  def self.enqueue_waitlist_cleanup(waiting_player_id : Int64, delay : Time::Span = Time::Span.zero) : Nil
    enqueue(delay) do
      WaitlistCleanupJob.enqueue(waiting_player_id)
    end
  end

  def self.enqueue_matchmaking(waiting_player_id : Int64) : Nil
    MatchmakingJob.enqueue(waiting_player_id)
  end

  def self.enqueue_room_maintenance(room_id : Int64, delay : Time::Span = Time::Span.zero) : Nil
    enqueue(delay) do
      RoomMaintenanceJob.enqueue(room_id)
    end
  end

  def self.enqueue_game_processing(game_id : Int64, delay : Time::Span = Time::Span.zero) : Nil
    enqueue(delay) do
      GameProcessingJob.enqueue(game_id)
    end
  end

  private def self.enqueue(delay : Time::Span, &block : -> Nil) : Nil
    if delay <= Time::Span.zero
      block.call
      return
    end
    if ENV[DISABLE_DELAYED_ENQUEUE_ENV_KEY]? == "1"
      return
    end

    spawn do
      sleep delay
      block.call
    end
  end
end
