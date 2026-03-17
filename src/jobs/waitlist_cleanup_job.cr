class WaitlistCleanupJob < Crumble::Jobs::Job
  STALE_WAITING_PLAYER_AGE = 20.seconds
  params waiting_player_id : Int64

  def perform : Nil
    stale_before = STALE_WAITING_PLAYER_AGE.ago
    unless waiting_player = WaitingPlayer.where(id: waiting_player_id).first?
      return
    end

    if waiting_player.created_at >= stale_before
      return
    end
    if waiting_player.online?
      return
    end

    waiting_player.destroy
  end
end
