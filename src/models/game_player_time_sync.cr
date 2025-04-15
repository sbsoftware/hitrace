class GamePlayerTimeSync < ApplicationRecord
  column game_player_id : Int64
  column client_time_ms : Int64
  column server_time_ms : Int64
end
