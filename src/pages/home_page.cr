require "./application_page"

class HomePage < ApplicationPage
  def self.root_path
    "/"
  end

  view HomeView
end
