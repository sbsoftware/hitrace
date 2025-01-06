class RoomView < Crumble::ContextView
  getter room : Room

  def initialize(@ctx, @room); end

  ToHtml.instance_template do
    a href: HomeResource.uri_path do
      "Home"
    end

    h1 { room.name }

    div do
      room.room_players.find { |rp| rp.session_id == ctx.session.id.to_s }.try(&.connection_check_action_template)

      room.set_ready_action_template.to_html do
        button { "Ready!" }
      end
    end

    div do
      room.player_list
    end
  end
end
