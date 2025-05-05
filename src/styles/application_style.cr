class ApplicationStyle < CSS::Stylesheet
  css_class LegalText

  rules do
    rule LegalText do
      width 750.px
      maxWidth 100.vw
      backgroundColor "#DDD"
      color Black
      padding 15.px
      prop("box-sizing", "border-box")
      prop("word-wrap", "break-word")
    end

    rule LegalText >> a do
      color Black
    end
  end
end
