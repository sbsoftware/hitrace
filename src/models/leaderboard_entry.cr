require "./application_record"

class LeaderboardEntry < ApplicationRecord
  column user_id : Int64
  column games_won : Int64
  column created_at : Time
  column updated_at : Time

  getter user : User do
    User.find(user_id)
  end

  def player_name
    user.display_name
  end
end
