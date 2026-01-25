require "../spec_helper"

describe Crumble::Turbo::ActionRegistry do
  it "returns false for non-action paths" do
    request_ctx = Crumble::Server::TestRequestContext.new(
      method: "GET",
      resource: "/"
    )

    Crumble::Turbo::ActionRegistry.handle(request_ctx).should be_false
  end
end
