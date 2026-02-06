require "../spec_helper"

describe SetNameAction do
  describe ".handle" do
    it "updates the session user name from request payload" do
      request_ctx = Crumble::Server::TestRequestContext.new(
        method: "POST",
        resource: SetNameAction.uri_path,
        body: URI::Params.encode({name: "Alice"})
      )

      SetNameAction.handle(request_ctx).should be_true
      request_ctx.session.user.not_nil!.name.should eq("Alice")
    end

    it "rejects submissions when the user already has a name" do
      user = User.create(name: "ExistingAda")
      request_ctx = Crumble::Server::TestRequestContext.new(
        method: "POST",
        resource: SetNameAction.uri_path,
        body: URI::Params.encode({name: "Grace"})
      )
      request_ctx.session.update!(user_id: user.id.value)

      SetNameAction.handle(request_ctx).should be_true
      request_ctx.response.status_code.should eq(403)
      User.where(id: user.id).first.not_nil!.name.should eq("ExistingAda")
    end
  end

  describe "#action_template" do
    it "hides the action when the user already has a name" do
      user = User.create(name: "NamedBob")
      request_ctx = Crumble::Server::TestRequestContext.new(method: "GET", resource: "/")
      request_ctx.session.update!(user_id: user.id.value)

      SetNameAction.new(request_ctx).action_template.to_html.should be_empty
    end
  end
end
