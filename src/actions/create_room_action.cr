class CreateRoomAction < Crumble::Turbo::Action
  controller do
    user = ctx.session.ensure_user

    created_room = ApplicationRecord.transaction do
      room = Room.create(name: "#{user.display_name}'s Room")
      RoomPlayer.create(room_id: room.id, user_id: user.id, admin: true)
      room
    end.not_nil!

    ctx.response.status_code = 303
    ctx.response.headers["Location"] = RoomPage.uri_path(created_room.id)
  end

  view do
    template do
      action_form.to_html do
        GameButton.to_html { "Play With A Friend" }
      end
    end
  end
end
