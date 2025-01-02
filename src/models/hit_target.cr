require "./application_record"

class HitTarget < ApplicationRecord
  column game_id : Int64
  column pos_x : Int32
  column pos_y : Int32

  def game
    Game.find(game_id)
  end

  model_action :hit, game.grid do
    def model_action_controller
      model.db.exec "DELETE FROM #{model.table_name} WHERE id=#{model.id}"

      model_template.turbo_stream.to_html(ctx.response)
    end
  end
end
