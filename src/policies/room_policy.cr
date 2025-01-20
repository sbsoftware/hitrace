class RoomPolicy
  getter session : Crumble::Server::SessionDecorator

  def initialize(@session); end

  def create?(room)
    true
  end

  def show?(room)
    room.room_players.any? do |room_player|
      room_player.session_id == session.id.to_s
    end
  end
end
