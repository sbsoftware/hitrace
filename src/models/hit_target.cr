require "./application_record"

class HitTarget < ApplicationRecord
  column game_id : Int64
  column pos_x : Int32
  column pos_y : Int32
  column delay_ms : Int32

  def game
    Game.find(game_id)
  end

  model_action :hit, nil do
    @game_player : GamePlayer?

    def game_player
      @game_player ||= model.game.game_players.find! do |gp|
        gp.session_id == ctx.session.id.to_s
      end
    end

    def model_template : IdentifiableView
      game_player.grid
    end

    def model_action_controller
      model.destroy
      game_player.score = game_player.score.value + 1
      game_player.save

      model_template.turbo_stream.to_html(ctx.response)
      model.game.game_players.each do |game_player|
        Crumble::Turbo::ModelTemplateRefreshService.notify(game_player.game_view)
      end
    end
  end

  ToHtml.instance_template do
    hit_action_template.to_html do
      nil
    end
  end
end
