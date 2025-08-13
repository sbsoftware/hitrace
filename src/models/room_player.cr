require "./application_record"

class RoomPlayer < ApplicationRecord
  column room_id : Int64
  column user_id : Int64
  column ready : Bool = false
  column last_connection_check_at : Time?

  def room
    Room.find(room_id)
  end

  getter user : User do
    User.find(user_id)
  end

  def player_name
    user.display_name
  end

  health_check_action :connection_check, 5.seconds, room.player_list do
    def model_action_controller
      return unless model
      return unless model.user_id == ctx.session.user_id

      model.last_connection_check_at = Time.utc
      model.save

      if game_id = model.room.game_id
        ctx.response.status_code = 303
        ctx.response.headers["Location"] = GameResource.uri_path(game_id)
      end
    end
  end

  def online?
    (last_check = last_connection_check_at) && last_check >= 10.seconds.ago
  end

  def reset!
    self.ready = false
    save
  end
end
