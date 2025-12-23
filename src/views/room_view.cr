class RoomView
  include Crumble::ContextView

  getter room_player : RoomPlayer

  delegate :room, to: room_player

  ToHtml.instance_template do
    a href: HomePage.uri_path do
      GameButton.to_html { "Leave Room" }
    end

    h1 { room.name }

    div do
      if room_player.admin.value
        room.share_element.to_html do
          GameButton.to_html { "Share" }
        end
      end

      room_player.connection_check_action_template(ctx)
    end

    div do
      room.player_list.renderer(ctx)
    end

    room.set_ready_action_template(ctx)
  end
end
