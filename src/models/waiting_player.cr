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
    def waiting_player
      WaitingPlayer.where(id: model_id).first?
    end

    controller do
      if game_player = GamePlayer.where(session_id: ctx.session.id.to_s).find { |gp| !gp.game.finished? }
        ctx.response.status_code = 303
        ctx.response.headers["Location"] = GameResource.uri_path(game_player.game_id)
        return
      end

      if (waiting_player = self.waiting_player).nil?
        ctx.response.status_code = 303
        ctx.response.headers["Location"] = HomeResource.uri_path
        return
      end

      waiting_player.update(last_connection_check_at: Time.utc)
    end
  end
end
