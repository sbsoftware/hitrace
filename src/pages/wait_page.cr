require "./application_page"

class WaitPage < ApplicationPage
  getter waiting_player : WaitingPlayer?

  before do
    unless (user = ctx.session.user) && (waiting_player = user.waiting_player)
      redirect HomePage.uri_path
      return 303
    end

    @waiting_player = waiting_player
    true
  end

  view do
    def waiting_player
      ctx.handler.as(WaitPage).waiting_player.not_nil!
    end

    template do
      h3 { "Waiting for another player..." }

      a href: HomePage.uri_path do
        "Home"
      end

      waiting_player.connection_check_action_template(ctx)
      waiting_player.spinner.renderer(ctx)
    end
  end
end
