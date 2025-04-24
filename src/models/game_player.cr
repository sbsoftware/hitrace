require "./application_record"
require "./game_player_time_sync"

class GamePlayer < ApplicationRecord
  column game_id : Int64
  column player_name : String
  column session_id : String
  column score : Int32 = 0
  # TODO: Bug in orma forces us to silently leave this column in
  column last_connection_check_at : Time?

  has_many_of GamePlayerTimeSync

  @game : Game?
  @sync_delays : Array(Int64)?

  def game
    @game ||= Game.find(game_id)
  end

  def ready?
    game_player_time_syncs.count >= 5
  end

  def sync_delays
    @sync_delays ||= game_player_time_syncs.to_a.reduce([] of Int64) do |memo, time_sync|
      memo << (time_sync.server_time_ms.value - time_sync.client_time_ms.value)
      memo
    end
  end

  def delay_ms : Int64
    return 0_i64 if sync_delays.empty?

    sync_delays.sort![(sync_delays.size / 2).to_i - 1]
  end

  def target_visible_at(hit_target)
    (game.started_at.try(&.value) || Time.utc) + hit_target.delay_ms.value.milliseconds - delay_ms.milliseconds
  end

  def target_visible_until(hit_target)
    hit_at = hit_target.hit_at_ms
    return 1.hour.from_now unless hit_at

    Time.unix_ms(hit_at.value) - delay_ms.milliseconds + 500.milliseconds
  end

  def player_color_class
    other_player = game.game_players.find! { |gp| gp != self }

    other_player.id > id ? PlayerColor1 : PlayerColor2
  end

  css_class GameContainer
  css_class PlayerColor1
  css_class PlayerColor2

  style do
    rule PlayerColor1 do
      backgroundColor "#FF7675"
      prop("box-shadow", "none")
    end

    rule PlayerColor2 do
      backgroundColor "#74B9FF"
      prop("box-shadow", "none")
    end
  end

  model_template :game_view do
    div GameContainer do
      if !game.started?
        p do
          "Loading"
        end
      elsif game.running?
        div do
          game.leaderboard
        end
        div do
          grid
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

  stimulus_controller TimeSyncController do
    targets :submit, :time

    js_method :connect do
      this.timeTarget.value = Date.now._call
      this.submitTarget.click._call

      that = this
      [200, 400, 600, 800].forEach do |delay|
        setTimeout(-> {
          that.timeTarget.value = Date.now._call
          that.submitTarget.click._call
        }, delay)
      end
    end
  end

  class TimeSyncTemplate
    getter action_path : String

    def initialize(@action_path); end

    css_class Form

    style do
      rule Form do
        display None
      end
    end

    ToHtml.instance_template do
      div TimeSyncController do
        form Form, action: action_path, method: "POST" do
          input TimeSyncController.time_target, type: :hidden, name: "time", value: "0"
          input TimeSyncController.submit_target, type: :submit, name: "submit"
        end
      end
    end
  end

  model_action :time_sync, game_view do
    def self.action_template(model)
      TimeSyncTemplate.new(self.uri_path(model.id))
    end

    controller do
      return unless body = ctx.request.body

      time = nil
      HTTP::Params.parse(body.gets_to_end) do |key, value|
        case key
        when "time"
          time = value.to_i64
        end
      end

      return unless time

      GamePlayerTimeSync.create(game_player_id: model.id, client_time_ms: time, server_time_ms: Time.utc.to_unix_ms)
    end
  end
end
