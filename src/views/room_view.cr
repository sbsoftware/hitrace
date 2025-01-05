class RoomView
  getter room : Room

  def initialize(@room); end

  ToHtml.instance_template do
    a href: HomeResource.uri_path do
      "Home"
    end

    h1 { room.name }

    div do
      room.set_ready_action_template.to_html do
        button { "Ready!" }
      end
    end

    div do
      room.player_list
    end
  end
end
