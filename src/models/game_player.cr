require "./application_record"

class GamePlayer < ApplicationRecord
  column game_id : Int64
  column player_name : String
  column session_id : String
  column score : Int32 = 0
  column last_connection_check_at : Time?

  @game : Game?

  def game
    @game ||= Game.find(game_id)
  end

  def online?
    (last_check_at = last_connection_check_at) && last_check_at >= 5.seconds.ago
  end

  def target_visible_at(hit_target)
    (game.started_at.try(&.value) || Time.utc) + hit_target.delay_ms.value.milliseconds + 100.milliseconds
  end

  css_class GameContainer

  model_template :game_view do
    div GameContainer do
      if game.running?
        div do
          grid
        end
        div do
          game.leaderboard
        end
      elsif game.finished?
        GameSummaryView.new(model.game)
      end
    end
  end

  model_template :grid do
    GameGridView.new(
      size_x: game.size_x.value,
      size_y: game.size_y.value,
      targets: game.hit_targets.to_a,
      game_player: model
    )
  end
end
