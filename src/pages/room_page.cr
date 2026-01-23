require "./application_page"

class RoomPage < ApplicationPage
  model room : Room, fallback_redirect: HomePage.uri_path

  getter room_player : RoomPlayer?

  before do
    room = self.room.not_nil!

    unless ctx.room_policy.show?(room)
      redirect HomePage.uri_path
      return 303
    end

    @room_player = room.room_players.find { |room_player| room_player.user_id == ctx.session.user_id }
    unless @room_player
      redirect HomePage.uri_path
      return 303
    end

    true
  end

  view do
    def room
      ctx.handler.as(RoomPage).room.not_nil!
    end

    def room_player
      ctx.handler.as(RoomPage).room_player.not_nil!
    end

    template do
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
end
