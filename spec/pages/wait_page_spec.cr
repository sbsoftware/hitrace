require "../spec_helper"

describe WaitPage do
  it "renders the wait page for a waiting player" do
    io = IO::Memory.new
    request_ctx = Crumble::Server::TestRequestContext.new(io, method: "GET", resource: WaitPage.uri_path)

    user = request_ctx.session.ensure_user
    WaitingPlayer.create(user_id: user.id)

    WaitPage.handle(request_ctx).should be_true
    request_ctx.response.close
    request_ctx.response.status_code.should eq(200)
    io.to_s.should contain("Waiting for another player...")
  end

  it "redirects home when the user is not waiting" do
    io = IO::Memory.new
    request_ctx = Crumble::Server::TestRequestContext.new(io, method: "GET", resource: WaitPage.uri_path)

    request_ctx.session.ensure_user

    WaitPage.handle(request_ctx).should be_true
    request_ctx.response.close
    request_ctx.response.status_code.should eq(303)
    request_ctx.response.headers["Location"].should eq(HomePage.uri_path)
  end
end
