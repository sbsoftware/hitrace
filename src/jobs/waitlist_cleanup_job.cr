class WaitlistCleanupJob < RecurringBackgroundJob
  STALE_WAITING_PLAYER_AGE = 20.seconds

  def run_iteration : Bool
    removed_waiting_player = false

    WaitingPlayer.all.each do |waiting_player|
      next unless waiting_player.created_at < STALE_WAITING_PLAYER_AGE.ago
      next if waiting_player.online?

      waiting_player.destroy
      removed_waiting_player = true
    end

    removed_waiting_player
  end
end
