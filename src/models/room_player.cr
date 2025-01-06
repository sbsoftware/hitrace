require "./application_record"

class RoomPlayer < ApplicationRecord
  column room_id : Int64
  column player_name : String
  column session_id : String
  column ready : Bool = false
  column last_connection_check_at : Time?

  def room
    Room.find(room_id)
  end

  health_check_action :connection_check, room.player_list do
    def model_action_controller
      return unless model
      return unless model.session_id == ctx.session.id.to_s

      model.last_connection_check_at = Time.utc
      model.save
    end
  end
end
