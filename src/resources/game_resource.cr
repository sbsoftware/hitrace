require "./application_resource"

class GameResource < ApplicationResource
  def show
    if game = Game.find(id)
      if ctx.game_policy.show?(game)
        render GameView.new(ctx: ctx, game: game)
      else
        redirect HomeResource.uri_path
      end
    end
  end
end
