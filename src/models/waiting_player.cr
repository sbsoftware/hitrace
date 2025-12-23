class WaitingPlayer < ApplicationRecord
  column user_id : Int64
  column last_connection_check_at : Time?
  column created_at : Time
  column updated_at : Time

  def user
    User.find(user_id)
  end

  def online?
    (last_online = last_connection_check_at) && last_online > 10.seconds.ago
  end

  model_template :spinner do
    div { "Loading Spinner" }
  end

  health_check_action :connection_check, 2.seconds, spinner do
    controller do
      if game_player = model.user.active_game_player
        ctx.response.status_code = 303
        ctx.response.headers["Location"] = GameResource.uri_path(game_player.game_id)
        return
      end

      model.update(last_connection_check_at: Time.utc)
    rescue e : Exception
      ctx.response.status_code = 303
      ctx.response.headers["Location"] = HomePage.uri_path
    end
  end
end
