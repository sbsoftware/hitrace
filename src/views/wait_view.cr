class WaitView
  include Crumble::ContextView

  getter waiting_player : WaitingPlayer

  ToHtml.instance_template do
    h3 { "Waiting for another player..." }

    a href: HomeResource.uri_path do
      "Home"
    end

    waiting_player.connection_check_action_template(ctx)

    waiting_player.spinner
  end
end
