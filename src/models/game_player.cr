require "./application_record"

class GamePlayer < ApplicationRecord
  column game_id : Int64
  column player_name : String
  column session_id : String
  column score : Int32 = 0
  column last_connection_check_at : Time?

  def game
    Game.find(game_id)
  end

  def online?
    (last_check_at = last_connection_check_at) && last_check_at >= 5.seconds.ago
  end

  health_check_action :connection_check, 2.seconds, game.default_view do
    def model_action_controller
      return unless model

      game = model.game

      if game
        model.last_connection_check_at = Time.utc
        model.save

        model_template.turbo_stream.to_html(ctx.response)
      else
        ctx.response.status_code = 303
        ctx.response.headers["Location"] = HomeResource.uri_path
      end
    end
  end
end
