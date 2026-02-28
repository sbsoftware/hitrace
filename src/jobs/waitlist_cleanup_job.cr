class WaitlistCleanupJob < RecurringBackgroundJob
  STALE_WAITING_PLAYER_AGE = 20.seconds

  def run_iteration : Bool
    removed_waiting_player = false
    stale_before = STALE_WAITING_PLAYER_AGE.ago

    WaitingPlayer.all.each do |waiting_player|
      if waiting_player.created_at >= stale_before
        logger.info { "Keeping waiting player #{waiting_player.id.value}: age below threshold (#{STALE_WAITING_PLAYER_AGE})" }
        next
      end
      if waiting_player.online?
        logger.info { "Keeping waiting player #{waiting_player.id.value}: stale but still online" }
        next
      end

      waiting_player.destroy
      removed_waiting_player = true
      logger.info { "Removed stale offline waiting player #{waiting_player.id.value}" }
    end

    logger.info { "No stale offline waiting players removed" } unless removed_waiting_player
    removed_waiting_player
  end
end
