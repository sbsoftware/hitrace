require "log"

module BackgroundJobs
  LOGGER = Log.for("background_jobs")

  def self.enqueue_startup_jobs : Nil
    LOGGER.info { "Enqueued startup job #{WaitlistCleanupJob.job_name} id=#{WaitlistCleanupJob.enqueue}" }
    LOGGER.info { "Enqueued startup job #{MatchmakingJob.job_name} id=#{MatchmakingJob.enqueue}" }
    LOGGER.info { "Enqueued startup job #{RoomMaintenanceJob.job_name} id=#{RoomMaintenanceJob.enqueue}" }
    LOGGER.info { "Enqueued startup job #{GameProcessingJob.job_name} id=#{GameProcessingJob.enqueue}" }
  end
end
