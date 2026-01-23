require "../spec_helper"

describe GamePage do
  it "renders a game for the active player" do
    game = Game.create
    io = IO::Memory.new
    request_ctx = Crumble::Server::TestRequestContext.new(
      io,
      method: "GET",
      resource: GamePage.uri_path(game.id)
    )

    user = request_ctx.session.ensure_user
    GamePlayer.create(game_id: game.id, user_id: user.id)

    GamePage.handle(request_ctx).should be_true
    request_ctx.response.close
    request_ctx.response.status_code.should eq(200)
    io.to_s.should contain("Loading")
  end
end
