class RoomPolicy
  getter session : Crumble::Server::SessionDecorator

  def initialize(@session); end

  def create?(room)
    true
  end

  def show?(room)
    room.room_players.any? do |room_player|
      room_player.user_id == session.user_id
    end
  end
end
