require "../spec_helper"

describe "Crumble::Page integration" do
  before_all do
    ENV["LEGAL_NOTICE_NAME"] = "Test Name"
    ENV["LEGAL_NOTICE_STREET"] = "Test Street 1"
    ENV["LEGAL_NOTICE_CITY"] = "Test City"
    ENV["LEGAL_NOTICE_PHONE"] = "0000"
    ENV["LEGAL_NOTICE_EMAIL"] = "test@example.invalid"
  end

  it "renders HomePage at /" do
    io = IO::Memory.new
    request_ctx = Crumble::Server::TestRequestContext.new(io, method: "GET", resource: "/")

    HomePage.handle(request_ctx).should be_true
    request_ctx.response.close
    request_ctx.response.status_code.should eq(200)
    io.to_s.should contain("Hit the target tiles faster than your opponent!")
  end

  it "renders PrivacyNoticePage at /privacy_notice" do
    io = IO::Memory.new
    request_ctx = Crumble::Server::TestRequestContext.new(io, method: "GET", resource: "/privacy_notice")

    PrivacyNoticePage.handle(request_ctx).should be_true
    request_ctx.response.close
    request_ctx.response.status_code.should eq(200)
    io.to_s.should contain("Datenschutzerklärung")
  end
end
