require "./application_record"
require "./hit_target"
require "./game_player"
require "../views/game_scoreboard_view"

class Game < ApplicationRecord
  GAME_DURATION = 30.seconds

  column size_x : Int32 = 5
  column size_y : Int32 = 5
  column started_at : Time?
  column room_id : Int64?
  column processing_completed : Bool = false

  has_many_of HitTarget
  has_many_of GamePlayer

  def room
    Room.where({"id" => room_id}).first?
  end

  def started?
    !started_at.nil?
  end

  def running?
    started? && !finished?
  end

  def finished?
    started_at.try(&.<=(GAME_DURATION.ago)) || false
  end

  model_template :leaderboard do
    GameScoreboardView.new(game: model)
  end
end
