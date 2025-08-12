require "./application_resource"

class RoomResource < ApplicationResource
  def create
    unless body = ctx.request.body
      redirect HomeResource.uri_path
      return
    end

    # FIXME: This doesn't work anymore with non-nilable `id` and current `orma` version
    room = Room.from_http_params(body.gets_to_end)
    if ctx.room_policy.create?(room)
      room.save
    else
      redirect HomeResource.uri_path
    end


    if (room_id = room.id) && (user_id = ctx.session.user_id)
      RoomPlayer.create(room_id: room_id, user_id: user_id)
    end

    redirect RoomResource.uri_path(room.id)
  end

  def show
    unless room = Room.where({"id" => id}).first?
      redirect HomeResource.uri_path
      return
    end
    unless ctx.room_policy.show?(room)
      redirect HomeResource.uri_path
      return
    end

    render RoomView.new(ctx: ctx, room: room)
  end
end
