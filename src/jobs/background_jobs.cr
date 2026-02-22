module BackgroundJobs
  def self.enqueue_startup_jobs : Nil
    WaitlistCleanupJob.enqueue
    MatchmakingJob.enqueue
    RoomMaintenanceJob.enqueue
    GameProcessingJob.enqueue
  end
end
