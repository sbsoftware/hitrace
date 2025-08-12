require "./application_record"

class LeaderboardEntry < ApplicationRecord
  deprecated_column session_id : String?
  deprecated_column player_name : String?
  # TODO: Make non-nilable after data migration v13
  column user_id : Int64?
  column games_won : Int64
  column created_at : Time
  column updated_at : Time

  def user
    User.find(user_id)
  end
end
