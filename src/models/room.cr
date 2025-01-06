require "./application_record"
require "./room_player"

class Room < ApplicationRecord
  column name : String

  has_many_of RoomPlayer

  model_template :player_list do
    ul do
      room_players.each do |room_player|
        li do
          room_player.player_name
          " "
          if (last_check = room_player.last_connection_check_at) && last_check >= 1.minute.ago
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

      unless model.room_players.any? { |rp| rp.session_id == ctx.session.id.to_s }
        if (room_id = model.id) && (player_name = ctx.session.player_name)
          player = RoomPlayer.new(room_id: room_id, player_name: player_name, session_id: ctx.session.id.to_s)
          player.save
        end
      end

      ctx.response.status_code = 303
      ctx.response.headers["Location"] = RoomResource.uri_path(model_id)
    end
  end

  model_action :set_ready, player_list do
    def model_action_controller
      return unless model

      if room_player = model.room_players.find { |rp| rp.session_id == ctx.session.id.to_s }
        room_player.ready = true
        room_player.save
      end

      model_template.turbo_stream.to_html(ctx.response)
    end
  end
end
