class WaitingPlayer < ApplicationRecord
  column session_id : String
  column player_name : String
  column last_connection_check_at : Time?
  column created_at : Time
  column updated_at : Time

  def online?
    (last_online = last_connection_check_at) && last_online > 10.seconds.ago
  end

  model_template :spinner do
    div { "Loading Spinner" }
  end

  health_check_action :connection_check, 2.seconds, spinner do
    controller do
      model.update(last_connection_check_at: Time.utc)

      if game_player = GamePlayer.where({"session_id" => ctx.session.id.to_s}).find { |gp| !gp.game.finished? }
        ctx.response.status_code = 303
        ctx.response.headers["Location"] = GameResource.uri_path(game_player.game_id)
      end
    end
  end
end
