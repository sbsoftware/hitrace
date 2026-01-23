require "./application_page"

class GamePage < ApplicationPage
  model game : Game, fallback_redirect: HomePage.uri_path

  getter game_player : GamePlayer?

  before do
    game = self.game.not_nil!

    unless (user = ctx.session.user) && ctx.game_policy.show?(game)
      redirect HomePage.uri_path
      return 303
    end

    @game_player = game.game_players.find { |gp| gp.user_id == user.id }
    unless @game_player
      redirect HomePage.uri_path
      return 303
    end

    true
  end

  view do
    def game_player
      ctx.handler.as(GamePage).game_player.not_nil!
    end

    template do
      game_player.time_sync_action_template(ctx) unless game_player.ready?
      game_player.game_view.renderer(ctx)
    end
  end
end
