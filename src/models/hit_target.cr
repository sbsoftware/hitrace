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
      return unless model

      if game_player = model.game.game_players.find { |gp| gp.session_id == ctx.session.id.to_s }
        model.db.exec "DELETE FROM #{model.table_name} WHERE id=#{model.id}"
        game_player.score = game_player.score.value + 1
        game_player.save
      end

      model_template.turbo_stream.to_html(ctx.response)
      Crumble::Turbo::ModelTemplateRefreshService.notify(model.game.leaderboard)
    end
  end

  ToHtml.instance_template do
    hit_action_template.to_html do
      nil
    end
  end
end
