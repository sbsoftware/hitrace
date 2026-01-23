require "../spec_helper"

describe RoomPage do
  it "renders a room for a member" do
    room = Room.create(name: "Test Room")
    io = IO::Memory.new
    request_ctx = Crumble::Server::TestRequestContext.new(
      io,
      method: "GET",
      resource: RoomPage.uri_path(room.id)
    )

    user = request_ctx.session.ensure_user
    RoomPlayer.create(room_id: room.id, user_id: user.id, admin: true)

    RoomPage.handle(request_ctx).should be_true
    request_ctx.response.close
    request_ctx.response.status_code.should eq(200)
    io.to_s.should contain("Leave Room")
  end
end
