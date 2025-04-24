class GameGridView
  getter size_x : Int32
  getter size_y : Int32
  getter targets : Array(HitTarget) | Array(FakeTarget)
  getter game_player : GamePlayer | FakeGamePlayer

  def initialize(@size_x, @size_y, @targets : Array(HitTarget), @game_player : GamePlayer); end

  def initialize(@size_x, @size_y)
    @targets = 2.times.map do
      FakeTarget.new(rand(1..size_x), rand(1..size_y))
    end.to_a
    @game_player = FakeGamePlayer.new
  end

  record FakeTarget, pos_x : Int32, pos_y : Int32 do
    def id
      Orma::Attribute(Int64).new(HitTarget, :id, 1)
    end

    def delay_ms
      Orma::Attribute(Int32).new(HitTarget, :delay_ms, 0)
    end

    def hit_at_ms
      nil
    end

    def hitting_game_player_id
      nil
    end

    def hitting_game_player
      nil
    end

    ToHtml.instance_template do
      nil # empty template
    end
  end

  record FakeGamePlayer do
    def target_visible_at(_target)
      Time.utc
    end

    def target_visible_until(_target)
      1.hour.from_now
    end
  end

  css_class Grid
  css_class Row
  css_class Cell
  css_class Target
  css_class HiddenTarget

  style do
    rule Grid do
      width 100.vw
      maxWidth 500.px
      height "auto"
      prop("aspect-ratio", "1 / 1")
    end

    rule Row do
      display Flex
      width 100.percent
      height 20.percent
    end

    rule Cell do
      width 20.percent
      height 100.percent
      border 1.px, Solid, White
    end

    rule Target do
      width 100.percent
      height 100.percent
      backgroundColor "#32CD32"
      prop("box-shadow", "0px 0px 20px 10px rgba(0, 255, 0, 0.7)")
    end

    rule Target > any do
      width 100.percent
      height 100.percent
    end

    rule Target & ":active" do
      backgroundColor "#ffa500"
    end

    rule HiddenTarget do
      display None
    end
  end

  stimulus_controller HitTargetController do
    values visible_at: Int64, visible_until: Int64

    js_method :connect do
      now = Date.now._call
      return if this.hasVisibleUntilValue && this.visibleUntilValue <= now

      if this.visibleAtValue <= now
        this.show._call
        if this.hasVisibleUntilValue
          this.timer = setTimeout(-> { this.hide._call }, this.visibleUntilValue - now)
        end
      else
        this.timer = setTimeout(-> { this.show._call }, this.visibleAtValue - now)
      end
    end

    js_method :disconnect do
      if this.timer
        clearTimeout(this.timer)
      end
    end

    js_method :show do
      this.element.classList.remove(HiddenTarget.to_js_ref)
    end

    js_method :hide do
      this.element.classList.add(HiddenTarget.to_js_ref)
    end
  end

  ToHtml.instance_template do
    now = Time.utc.to_unix_ms
    div Grid do
      (1..size_x).each do |grid_x|
        div Row do
          (1..size_y).each do |grid_y|
            div Cell do
              targets.select { |t| t.pos_x == grid_x && t.pos_y == grid_y }.each do |target|
                unless (hit_at_ms = target.hit_at_ms) && (hit_at_ms + 500) < now
                  div Target, HiddenTarget, (target.hitting_game_player.try(&.player_color_class) if target.hitting_game_player_id), HitTargetController, HitTargetController.visible_at_value(game_player.target_visible_at(target).to_unix_ms.to_s), (HitTargetController.visible_until_value(game_player.target_visible_until(target).to_unix_ms.to_s) if target.hit_at_ms) do
                    target
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
