class GameView < Crumble::ContextView
  getter game : Game

  def initialize(@ctx, @game); end

  css_class GameContainer

  style do
    rule GameContainer do
      display Flex
    end
  end

  ToHtml.instance_template do
    game.game_players.find { |gp| gp.session_id == ctx.session.id.to_s }.try(&.connection_check_action_template)

    div GameContainer do
      div do
        game.grid
      end
      div do
        game.leaderboard
      end
    end
  end
end
