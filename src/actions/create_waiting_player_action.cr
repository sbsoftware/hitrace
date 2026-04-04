class CreateWaitingPlayerAction < Crumble::Turbo::Action
  controller do
    user = ctx.session.ensure_user
    unless user.waiting_player
      waiting_player = WaitingPlayer.create(user_id: user.id)
      BackgroundJobs.enqueue_waitlist_cleanup(waiting_player.id.value, delay: WaitlistCleanupJob::STALE_WAITING_PLAYER_AGE)
    end

    ctx.response.status_code = 303
    ctx.response.headers["Location"] = WaitPage.uri_path
  end

  view do
    template do
      action_form.to_html do
        GameButton.to_html { "Play Now" }
      end
    end
  end
end
