require "../spec_helper"

describe CreateWaitingPlayerAction do
  describe ".handle" do
    it "creates a waiting player and redirects to the wait page" do
      request_ctx = Crumble::Server::TestRequestContext.new(method: "POST", resource: CreateWaitingPlayerAction.uri_path)

      CreateWaitingPlayerAction.handle(request_ctx).should be_true
      request_ctx.response.status_code.should eq(303)
      request_ctx.response.headers["Location"].should eq(WaitPage.uri_path)
      request_ctx.session.user.not_nil!.waiting_player.should_not be_nil
    end

    it "does not create a duplicate waiting player" do
      user = User.create
      WaitingPlayer.create(user_id: user.id)
      request_ctx = Crumble::Server::TestRequestContext.new(method: "POST", resource: CreateWaitingPlayerAction.uri_path)
      request_ctx.session.update!(user_id: user.id.value)

      CreateWaitingPlayerAction.handle(request_ctx).should be_true
      request_ctx.response.status_code.should eq(303)
      WaitingPlayer.where(user_id: user.id).count.should eq(1)
    end
  end
end
