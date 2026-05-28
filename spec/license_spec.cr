require "./spec_helper"

describe "LICENSE" do
  it "excludes third-party legal text pages and their contents from the MIT license" do
    license = File.read("LICENSE")

    license.should contain("Excluded Legal Texts")
    license.should contain("src/pages/legal_notice_page.cr")
    license.should contain("src/pages/privacy_notice_page.cr")
    license.should contain("their respective contents are excluded")
    license.should contain("under the terms of this MIT License")
  end
end
