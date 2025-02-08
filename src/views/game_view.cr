class GameView
  include Crumble::ContextView

  getter game : Game

  ToHtml.instance_template do
    game.game_players.find { |gp| gp.session_id == ctx.session.id.to_s }.try(&.connection_check_action_template)

    game.default_view
  end
end
