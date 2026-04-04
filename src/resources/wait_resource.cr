class WaitResource < ApplicationResource
  def index
    return unless user = ctx.session.user

    unless player = user.waiting_player
      redirect HomePage.uri_path
      return
    end

    render WaitView.new(ctx: ctx, waiting_player: player)
  end

  def create
    user = ctx.session.ensure_user

    unless user.waiting_player
      waiting_player = WaitingPlayer.create(user_id: user.id)
      BackgroundJobs.enqueue_waitlist_cleanup(waiting_player.id.value, delay: WaitlistCleanupJob::STALE_WAITING_PLAYER_AGE)
    end

    redirect WaitResource.uri_path
  end
end
