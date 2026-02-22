abstract class RecurringBackgroundJob < Crumble::Jobs::Job
  params

  RESCHEDULE_INTERVAL        = 1.second
  RESCHEDULE_DISABLE_ENV_KEY = "HIT_DISABLE_JOB_RESCHEDULE"

  abstract def run_iteration : Bool

  def perform : Nil
    enqueue_immediately = false

    begin
      enqueue_immediately = run_iteration
    ensure
      # Keep recurring jobs alive even when an iteration raises.
      schedule_next(immediate: enqueue_immediately)
    end
  end

  private def schedule_next(*, immediate : Bool) : Nil
    return if ENV[RESCHEDULE_DISABLE_ENV_KEY]? == "1"

    if immediate
      self.class.enqueue
    else
      spawn do
        sleep RESCHEDULE_INTERVAL
        self.class.enqueue
      end
    end
  end
end
