require "./application_record"
require "./room_player"

class Room < ApplicationRecord
  column name : String
  column game_id : Int64?
  column last_game_started_at : Time?

  has_many_of RoomPlayer

  def ready?
    game_id.nil? && room_players.size > 0 && room_players.all? do |room_player|
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
    def model_action_controller
      return unless model

      unless player = model.room_players.any? { |rp| rp.user_id == ctx.session.user_id }
        if (room_id = model.id) && model.game_id.nil? && (user_id = ctx.session.user_id)
          player = RoomPlayer.create(room_id: room_id, user_id: user_id)
        end
      end

      if player
        ctx.response.status_code = 303
        ctx.response.headers["Location"] = RoomResource.uri_path(model_id)
      end
    end
  end

  model_action :set_ready, player_list do
    def model_action_controller
      return unless model

      if room_player = model.room_players.find { |rp| rp.user_id == ctx.session.user_id }
        room_player.ready = true
        room_player.save
      end

      model_template.turbo_stream.to_html(ctx.response)
    end
  end
end
