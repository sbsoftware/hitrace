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

  model_action :join, player_list do
    controller do
      return unless model

      unless player = model.room_players.any? { |rp| rp.user_id == ctx.session.user_id }
        if (room_id = model.id) && model.game_id.nil? && (user_id = ctx.session.user_id)
          player = RoomPlayer.create(room_id: room_id, user_id: user_id)
        end
      end

      if player
        ctx.response.status_code = 303
        ctx.response.headers["Location"] = RoomResource.uri_path(model.id)
      end
    end

    view do
      # TODO: This probably needs a button
      template do
        action_form.to_html { nil }
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

  accessible RoomPlayer, RoomResource, player_list do
    access_view do
      css_class Description
      css_class JoinButton
      css_class FakeGrid

      style do
        rule Description do
          display Flex
          justifyContent Center
          fontSize 18.px
          marginBottom 15.px
        end

        rule JoinButton do
          display Flex
          justifyContent Center
        end

        rule FakeGrid do
          prop("margin-top", 15.px)
          display Flex
          justifyContent Center
        end

        rule FakeGrid > GameGridView::Grid do
          prop("transform", "perspective(800px) scale(0.6) translate(0, -120px) rotateX(35deg) rotateZ(28deg) rotateY(-15deg) translate(-40px, -60px)")
          prop("box-shadow", "0px 50px 30px 20px rgba(30, 30, 30, 0.5)")
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
