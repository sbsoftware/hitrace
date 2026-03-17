require "./game_button"

class PlayButtonView
  include Crumble::ContextView

  ToHtml.instance_template do
    CreateWaitingPlayerAction.new(ctx).action_template
  end
end
