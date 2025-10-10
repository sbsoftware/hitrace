require "./game_button"

class PlayButtonView
  ToHtml.class_template do
    form action: WaitResource.uri_path, method: "POST" do
      GameButton.to_html { "Play Now" }
    end
  end
end
