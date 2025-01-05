require "./application_record"

class RoomPlayer < ApplicationRecord
  column room_id : Int64
  column player_name : String
  column session_id : String
  column ready : Bool = false

  def room
    Room.find(room_id)
  end
end
