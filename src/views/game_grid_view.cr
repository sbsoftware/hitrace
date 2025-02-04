class GameGridView
  getter size_x : Int32
  getter size_y : Int32
  getter targets : Array(HitTarget) | Array(FakeTarget)

  def initialize(@size_x, @size_y, @targets); end

  def initialize(@size_x, @size_y)
    @targets = 2.times.map do
      FakeTarget.new(rand(1..size_x), rand(1..size_y))
    end.to_a
  end

  record FakeTarget, pos_x : Int32, pos_y : Int32 do
    ToHtml.instance_template do
      nil # empty template
    end
  end

  css_class Grid
  css_class Row
  css_class Cell
  css_class Target

  style do
    rule Grid do
      width 100.vw
      maxWidth 500.px
      height 100.percent
    end

    rule Row do
      display Flex
      width 100.percent
      height 10.vh
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
    end

    rule Target > any do
      width 100.percent
      height 100.percent
    end
  end

  ToHtml.instance_template do
    div Grid do
      (1..size_x).each do |grid_x|
        div Row do
          (1..size_y).each do |grid_y|
            div Cell do
              if target = targets.find { |t| t.pos_x == grid_x && t.pos_y == grid_y }
                div Target do
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
