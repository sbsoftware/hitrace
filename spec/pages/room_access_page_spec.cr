require "../spec_helper"

describe Room::AccessPage do
  it "renders invite metadata and landing content" do
    room = Room.find(Room.create(name: "Test Room").id)
    io = IO::Memory.new
    request_ctx = Crumble::Server::TestRequestContext.new(
      io,
      method: "GET",
      resource: Room::AccessPage.uri_path(access_token: room.access_token.value)
    )

    Room::AccessPage.handle(request_ctx).should be_true
    request_ctx.response.close
    request_ctx.response.status_code.should eq(200)

    html = io.to_s
    html.should contain("<title>Join Test Room on HITRACE</title>")
    html.should contain(%(property="og:title"))
    html.should contain(%(content="Join Test Room on HITRACE"))
    html.should contain(%(property="og:description"))
    html.should contain(%(content="#{room.invite_description}"))
    html.should contain(%(property="og:url"))
    html.should contain(%(content="#{room.share_uri}"))
    html.should contain(%(property="og:image"))
    html.should contain(%(content="#{room.invite_preview_image_uri}"))
    html.should contain(%(name="twitter:card"))
    html.should contain(%(content="summary_large_image"))
    html.should contain("How it works:")
    html.should contain("Join game")
    html.should contain(%(src="#{Room::InvitePreviewImage.uri_path}"))
  end

  it "accepts an invite and redirects to the room page" do
    room = Room.find(Room.create(name: "Test Room").id)
    io = IO::Memory.new
    request_ctx = Crumble::Server::TestRequestContext.new(
      io,
      method: "POST",
      resource: Room::AcceptAccessAction.uri_path(room.id),
      body: "access_token=#{room.access_token.value}"
    )
    user = request_ctx.session.ensure_user

    Room::AcceptAccessAction.handle(request_ctx).should be_true
    request_ctx.response.close
    request_ctx.response.status_code.should eq(303)
    request_ctx.response.headers["Location"].should eq(RoomPage.uri_path(room.id))
    RoomPlayer.where(room_id: room.id, user_id: user.id).count.should eq(1)
  end
end
