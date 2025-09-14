class CreateRoomAction < Crumble::Turbo::Action
  controller do
    user = ctx.session.ensure_user

    room = Room.create(name: "Private Room")
    RoomPlayer.create(room_id: room.id, user_id: user.id)

    ctx.response.status_code = 303
    ctx.response.headers["Location"] = RoomResource.uri_path(room.id)
  end

  view do
    template do
      action_form.to_html do
        GameButton.to_html { "Play With A Friend" }
      end
    end
  end
end
