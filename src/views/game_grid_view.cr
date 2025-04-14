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
    def delay_ms
      Orma::Attribute(Int32).new(HitTarget, :delay_ms, 0)
    end

    ToHtml.instance_template do
      nil # empty template
    end
  end

  record FakeGamePlayer do
    def target_visible_at(_target)
      Time.utc
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

    rule HiddenTarget do
      display None
    end
  end

  stimulus_controller HitTargetController do
    values visible_at: Int64

    js_method :connect do
      now = Date.now._call
      if this.visibleAtValue <= now
        this.element.classList.remove(HiddenTarget.to_js_ref)
      else
        setTimeout(-> { this.element.classList.remove(HiddenTarget.to_js_ref) }, this.visibleAtValue - now)
      end
    end
  end

  ToHtml.instance_template do
    div Grid do
      (1..size_x).each do |grid_x|
        div Row do
          (1..size_y).each do |grid_y|
            div Cell do
              if target = targets.find { |t| t.pos_x == grid_x && t.pos_y == grid_y }
                div Target, HiddenTarget, HitTargetController, HitTargetController.visible_at_value(game_player.target_visible_at(target).to_unix_ms.to_s) do
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
