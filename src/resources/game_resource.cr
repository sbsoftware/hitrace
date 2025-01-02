require "./application_resource"

class GameResource < ApplicationResource
  def create
    game = Game.new(size_x: 5, size_y: 5)
    game.save

    if game_id = game.id
      target1 = HitTarget.new(game_id: game_id, pos_x: 2, pos_y: 2)
      target1.save
      target2 = HitTarget.new(game_id: game_id, pos_x: 4, pos_y: 4)
      target2.save
    end

    redirect GameResource.uri_path(game.id)
  end

  def show
    if game = Game.find(id)
      render game.grid
    end
  end
end
