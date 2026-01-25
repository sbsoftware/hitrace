require "./application_record"
require "./room_player"

class Room < ApplicationRecord
  column name : String
  column game_id : Int64?
  column last_game_started_at : Time?

  has_many_of RoomPlayer

  def ready?
    game_id.nil? && room_players.size == 2 && room_players.all? do |room_player|
      room_player.ready.value && room_player.online?
    end
  end

  def reset!
    self.game_id = nil
    save

    room_players.each(&.reset!)
  end

  model_template :player_list do
    ul do
      room_players.each do |room_player|
        li do
          room_player.player_name
          " "
          if room_player.online?
            "(online)"
          end
          if room_player.ready.value
            " (ready)"
          end
        end
      end
    end
  end

  model_action :set_ready, player_list do
    controller do
      return unless model

      if room_player = model.room_players.find { |rp| rp.user_id == ctx.session.user_id }
        room_player.ready = true
        room_player.save
      end
    end

    view do
      template do
        action_form.to_html do
          GameButton.to_html { "Ready!" }
        end
      end
    end
  end

  accessible RoomPlayer, RoomPage, player_list do
    access_view do
      css_class Description
      css_class JoinButton
      css_class FakeGrid

      style do
        rule Description do
          display :flex
          justify_content :center
          font_size 18.px
          margin_bottom 15.px
        end

        rule JoinButton do
          display :flex
          justify_content :center
        end

        rule FakeGrid do
          margin_top 15.px
          display :flex
          justify_content :center
        end

        rule FakeGrid > GameGridView::Grid do
          transform(
            perspective(800.px),
            scale(0.6),
            translate(0, -120.px),
            rotate_x(35.deg),
            rotate_z(28.deg),
            rotate_y(-15.deg),
            translate(-40.px, -60.px)
          )
          box_shadow 0.px, 50.px, 30.px, 20.px, rgb(30, 30, 30, alpha: 50.percent)
        end
      end

      template do
        div Description do
          "You have been invited to join #{model.name}!"
        end

        div JoinButton do
          model.accept_access_action_template(ctx)
        end

        div FakeGrid do
          GameGridView.new(ctx: ctx, size_x: 5, size_y: 5)
        end
      end
    end

    accept_access_view do
      template do
        GameButton.to_html { "Join" }
      end
    end

    access_model_attributes user_id: ctx.session.ensure_user.id
  end
end
