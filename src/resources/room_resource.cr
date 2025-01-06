require "./application_resource"

class RoomResource < ApplicationResource
  def create
    unless body = ctx.request.body
      redirect HomeResource.uri_path
      return
    end

    room = Room.from_http_params(body.gets_to_end)
    if ctx.room_policy.create?(room)
      room.save
    else
      redirect HomeResource.uri_path
    end


    if (room_id = room.id) && (player_name = ctx.session.player_name)
      room_player = RoomPlayer.new(room_id: room_id, player_name: player_name, session_id: ctx.session.id.to_s)
      room_player.save
    end

    redirect RoomResource.uri_path(room.id)
  end

  def show
    unless room = Room.find(id)
      redirect HomeResource.uri_path
      return
    end
    unless ctx.room_policy.show?(room)
      redirect HomeResource.uri_path
      return
    end

    render RoomView.new(ctx, room)
  end
end
