require "log"

module BackgroundJobs
  LOGGER                          = Log.for("background_jobs")
  DISABLE_DELAYED_ENQUEUE_ENV_KEY = "HIT_DISABLE_DELAYED_JOB_ENQUEUE"

  def self.enqueue_waitlist_cleanup(waiting_player_id : Int64, delay : Time::Span = Time::Span.zero) : Nil
    enqueue(delay) do
      job_id = WaitlistCleanupJob.enqueue(waiting_player_id)
      LOGGER.info { "Enqueued #{WaitlistCleanupJob.job_name} for waiting_player_id=#{waiting_player_id} id=#{job_id}" }
    end
  end

  def self.enqueue_matchmaking(waiting_player_id : Int64) : Nil
    job_id = MatchmakingJob.enqueue(waiting_player_id)
    LOGGER.info { "Enqueued #{MatchmakingJob.job_name} for waiting_player_id=#{waiting_player_id} id=#{job_id}" }
  end

  def self.enqueue_room_maintenance(room_id : Int64, delay : Time::Span = Time::Span.zero) : Nil
    enqueue(delay) do
      job_id = RoomMaintenanceJob.enqueue(room_id)
      LOGGER.info { "Enqueued #{RoomMaintenanceJob.job_name} for room_id=#{room_id} id=#{job_id}" }
    end
  end

  def self.enqueue_game_processing(game_id : Int64, delay : Time::Span = Time::Span.zero) : Nil
    enqueue(delay) do
      job_id = GameProcessingJob.enqueue(game_id)
      LOGGER.info { "Enqueued #{GameProcessingJob.job_name} for game_id=#{game_id} id=#{job_id}" }
    end
  end

  private def self.enqueue(delay : Time::Span, &block : -> Nil) : Nil
    if delay <= Time::Span.zero
      block.call
      return
    end
    if ENV[DISABLE_DELAYED_ENQUEUE_ENV_KEY]? == "1"
      LOGGER.info { "Skipping delayed enqueue (#{delay}) due to #{DISABLE_DELAYED_ENQUEUE_ENV_KEY}=1" }
      return
    end

    LOGGER.info { "Scheduling delayed enqueue in #{delay}" }
    spawn do
      sleep delay
      block.call
    end
  end
end
