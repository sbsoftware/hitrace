require "./application_record"
require "./hit_target"

class Game < ApplicationRecord
  column size_x : Int32
  column size_y : Int32

  has_many_of HitTarget

  css_class Row
  css_class Cell
  css_class Target

  style do
    rule Row do
      display Flex
    end

    rule Cell do
      width 100.px
      height 100.px
      border 1.px, Solid, Black
    end

    rule Target do
      width 100.percent
      height 100.percent
      backgroundColor "#999900"
    end

    rule Target > any do
      width 100.percent
      height 100.percent
    end
  end

  model_template :grid do
    span style: "display: none;" do
      targets = hit_targets.to_a
    end
    div do
      (1..size_x.value).each do |grid_x|
        div Row do
          (1..size_y.value).each do |grid_y|
            div Cell do
              if target = targets.find { |t| t.pos_x == grid_x && t.pos_y == grid_y }
                div Target do
                  target.hit_action_template.to_html do
                    nil # need to provide a block
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
