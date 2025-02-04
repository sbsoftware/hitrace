require "./application_record"
require "./hit_target"
require "./game_player"

class Game < ApplicationRecord
  column size_x : Int32
  column size_y : Int32
  column started_at : Time?
  column room_id : Int64?

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
    started_at.try(&.<=(1.minute.ago))
  end

  css_class GameContainer

  model_template :default_view do
    div GameContainer do
      if running?
        div do
          grid
        end
        div do
          leaderboard
        end
      elsif finished?
        GameSummaryView.new(model)
      end
    end
  end

  model_template :grid do
    GameGridView.new(size_x: size_x.value, size_y: size_y.value, targets: hit_targets.to_a)
  end

  model_template :leaderboard do
    div do
      game_players.each do |game_player|
        div do
          span do
            game_player.player_name
          end
          " "
          span do
            game_player.score
          end
        end
      end
    end
  end
end
