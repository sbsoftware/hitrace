require "log"

abstract class RecurringBackgroundJob < Crumble::Jobs::Job
  params

  RESCHEDULE_INTERVAL        = 1.second
  RESCHEDULE_DISABLE_ENV_KEY = "HIT_DISABLE_JOB_RESCHEDULE"

  abstract def run_iteration : Bool

  def perform : Nil
    enqueue_immediately = false

    logger.info { "#{self.class.job_name} iteration started" }
    begin
      enqueue_immediately = run_iteration
      logger.info { "#{self.class.job_name} iteration finished (enqueue_immediately=#{enqueue_immediately})" }
    rescue error
      logger.error(exception: error) { "#{self.class.job_name} iteration failed" }
      raise error
    ensure
      # Keep recurring jobs alive even when an iteration raises.
      schedule_next(immediate: enqueue_immediately)
    end
  end

  private def schedule_next(*, immediate : Bool) : Nil
    if ENV[RESCHEDULE_DISABLE_ENV_KEY]? == "1"
      logger.info { "#{self.class.job_name} reschedule disabled via #{RESCHEDULE_DISABLE_ENV_KEY}" }
      return
    end

    if immediate
      logger.info { "#{self.class.job_name} scheduling immediate follow-up job" }
      logger.info { "#{self.class.job_name} enqueued follow-up job id=#{self.class.enqueue}" }
    else
      logger.info { "#{self.class.job_name} scheduling delayed follow-up job in #{RESCHEDULE_INTERVAL}" }
      spawn do
        sleep RESCHEDULE_INTERVAL
        logger.info { "#{self.class.job_name} enqueued delayed follow-up job id=#{self.class.enqueue}" }
      end
    end
  end

  private def logger : Log
    Log.for(self.class.job_name)
  end
end
