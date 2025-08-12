require "./application_record"

class HitTarget < ApplicationRecord
  column game_id : Int64
  column pos_x : Int32
  column pos_y : Int32
  column delay_ms : Int32
  column hitting_game_player_id : Int64?
  column hit_at_ms : Int64?

  def game
    Game.find(game_id)
  end

  def hitting_game_player
    GamePlayer.find(hitting_game_player_id)
  end

  model_action :hit, nil do
    @game_player : GamePlayer?

    def game_player
      @game_player ||= model.game.game_players.find! do |gp|
        gp.user_id == ctx.session.user_id
      end
    end

    def model_template : IdentifiableView
      game_player.grid
    end

    controller do
      # TODO: Transaction Start
      # TODO: Lock model?
      if model.hit_at_ms.nil?
        model.update(hitting_game_player_id: game_player.id, hit_at_ms: Time.utc.to_unix_ms)

        game_player.score = game_player.score.value + 1
        game_player.save
      end
      # TODO: Transaction End

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
