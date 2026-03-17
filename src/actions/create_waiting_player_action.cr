class CreateWaitingPlayerAction < Crumble::Turbo::Action
  controller do
    user = ctx.session.ensure_user
    WaitingPlayer.create(user_id: user.id) unless user.waiting_player

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
