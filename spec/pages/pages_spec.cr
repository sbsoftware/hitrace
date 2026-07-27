require "../spec_helper"

describe "Crumble::Page integration" do
  before_all do
    ENV["LEGAL_NOTICE_NAME"] = "Test Name"
    ENV["LEGAL_NOTICE_NAME2"] = "Test Name 2"
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
    io.to_s.should contain("Test Name 2")
  end

  it "renders LegalNoticePage at /legal_notice and includes font license links" do
    io = IO::Memory.new
    request_ctx = Crumble::Server::TestRequestContext.new(io, method: "GET", resource: "/legal_notice")

    LegalNoticePage.handle(request_ctx).should be_true
    request_ctx.response.close
    request_ctx.response.status_code.should eq(200)
    io.to_s.should contain("Impressum")
    io.to_s.should contain("Test Name 2")

    FONT_ASSETS.each do |font_asset|
      io.to_s.should contain(%(href="#{font_asset.license.uri_path}"))
    end
  end
end
