require "./application_resource"

class GameResource < ApplicationResource
  def show
    if game = Game.find(id)
      if (user = ctx.session.user) && ctx.game_policy.show?(game)
        game_player = game.game_players.find! do |gp|
          gp.user_id == user.id
        end
        render GameView.new(ctx: ctx, game_player: game_player)
      else
        redirect HomeResource.uri_path
      end
    end
  end
end
