class ApplicationStyle < CSS::Stylesheet
  css_class LegalText

  rule LegalText do
    width 750.px
    max_width 100.vw
    background_color "#DDD"
    color :black
    padding 15.px
    box_sizing :border_box
    word_wrap :break_word
    margin_bottom 50.px
    rule "a" do
      color :black
      text_decoration_line :underline
      text_decoration_color :black
    end
  end
end
