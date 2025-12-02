class GameButton
  css_class GameButton

  style do
    rule GameButton do
      background :transparent
      color :white
      border 1.px, :solid, :white
      border_radius 5.px
      box_shadow 0.px, 0.px, 2.px, 1.px, rgb(0, 255, 0, alpha: 70.percent)
      padding 10.px
      font_size 18.px
      font_family ApplicationLayout::Style::OutfitFont
      font_weight :bold
    end
  end

  ToHtml.class_template do
    button GameButton do
      yield
    end
  end
end
