require "./application_record"

class LeaderboardEntry < ApplicationRecord
  column session_id : String
  column player_name : String
  column games_won : Int64
  column created_at : Time
  column updated_at : Time
end
