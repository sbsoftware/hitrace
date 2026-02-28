require "log"

class WaitlistCleanupJob < Crumble::Jobs::Job
  STALE_WAITING_PLAYER_AGE = 20.seconds
  params waiting_player_id : Int64

  def perform : Nil
    stale_before = STALE_WAITING_PLAYER_AGE.ago
    unless waiting_player = WaitingPlayer.where(id: waiting_player_id).first?
      logger.info { "Skipping waitlist cleanup: waiting player #{waiting_player_id} not found" }
      return
    end

    if waiting_player.created_at >= stale_before
      logger.info { "Keeping waiting player #{waiting_player.id.value}: age below threshold (#{STALE_WAITING_PLAYER_AGE})" }
      return
    end
    if waiting_player.online?
      logger.info { "Keeping waiting player #{waiting_player.id.value}: stale but still online" }
      return
    end

    waiting_player.destroy
    logger.info { "Removed stale offline waiting player #{waiting_player.id.value}" }
  end

  private def logger : Log
    Log.for(self.class.job_name)
  end
end
