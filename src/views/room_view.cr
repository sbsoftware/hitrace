class RoomView
  include Crumble::ContextView

  getter room : Room

  ToHtml.instance_template do
    a href: HomeResource.uri_path do
      "Home"
    end

    h1 { room.name }

    div do
      room.room_players.find { |rp| rp.user_id == ctx.session.user_id }.try(&.connection_check_action_template(ctx))

      room.set_ready_action_template(ctx)
    end

    div do
      room.player_list
    end
  end
end
