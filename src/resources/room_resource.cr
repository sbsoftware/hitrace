require "./application_resource"

class RoomResource < ApplicationResource
  def show
    unless room = Room.where(id: id).first?
      redirect HomeResource.uri_path
      return
    end
    unless ctx.room_policy.show?(room)
      redirect HomeResource.uri_path
      return
    end

    room_player = room.room_players.find do |room_player|
      room_player.user_id == ctx.session.user_id
    end

    unless room_player
      redirect HomeResource.uri_path
      return
    end

    render RoomView.new(ctx: ctx, room_player: room_player)
  end
end
