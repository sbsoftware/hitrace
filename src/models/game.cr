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
  column created_at : Time

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

  def winner : GamePlayer?
    return unless finished?
    return if game_players.all?(&.score.value.zero?)

    max_score_player = game_players.max_by(&.score.value)
    return unless max_score_player

    max_score_player if game_players.select(&.score.==(max_score_player.score)).size == 1
  end

  model_template :leaderboard do
    GameScoreboardView.new(game: model)
  end
end
