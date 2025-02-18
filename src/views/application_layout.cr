# TODO: Move this to crumble/css.cr
class TTFFile < AssetFile
  def mime_type
    "font/ttf"
  end
end

class TXTFile < AssetFile
  def mime_type
    "text/plain"
  end
end

OutfitRegular = TTFFile.register "assets/fonts/Outfit/Outfit-Regular.ttf", "#{__DIR__}/../../assets/fonts/Outfit/Outfit-Regular.ttf"
OutfitLicense = TXTFile.register "assets/fonts/Outfit/OFL.txt", "#{__DIR__}/../../assets/fonts/Outfit/OFL.txt"
RubikSprayPaintRegular = TTFFile.register "assets/fonts/RubikSprayPaint/RubikSprayPaint.ttf", "#{__DIR__}/../../assets/fonts/Rubik_Spray_Paint/RubikSprayPaint-Regular.ttf"
RubikSprayPaintLicense = TXTFile.register "assets/fonts/RubikSprayPaint/OFL.txt", "#{__DIR__}/../../assets/fonts/Rubik_Spray_Paint/OFL.txt"

class ApplicationLayout < ToHtml::Layout
  include Crumble::ContextView

  css_class SiteHeading
  css_class SiteHeadingBegin
  css_class SiteHeadingEnd

  style do
    comment "License: https://hitrace.fun#{OutfitLicense.uri_path}"
    font_face do
      fontFamily "Outfit"
      fontStyle Normal
      src url(OutfitRegular.uri_path)
    end

    comment "License: https://hitrace.fun#{RubikSprayPaintLicense.uri_path}"
    font_face do
      fontFamily "Rubik Spray Paint"
      fontStyle Normal
      src url(RubikSprayPaintRegular.uri_path)
    end

    rule html do
      height 100.percent
      prop("background", "linear-gradient(180deg, rgba(2,7,13,1) 0%, rgba(20,80,139,1) 35%, rgba(84,60,182,1) 71%, rgba(76,30,119,1) 100%)")
      color White
    end

    rule body do
      display Flex
      justifyContent Center
      alignItems Center
      flexDirection Column
      fontFamily "Outfit, sans-serif"
    end

    rule a do
      color White
    end

    rule SiteHeading do
      fontSize "50pt"
      fontFamily "Rubik Spray Paint"
      fontWeight Normal
    end

    rule SiteHeadingBegin do
      prop("text-shadow", outline_shadow("#8F7", 5))
      color "#c829d1"
    end

    rule SiteHeadingEnd do
      prop("background", "#09d5d7")
      prop("background-clip", "text")
      color "transparent"
    end
  end

  class JsErrorHandler < JS::Code
    def_to_js do
      self.addEventListener("error", ->(event) {
        window.alert(event.message)
      })
      self.addEventListener("unhandledrejection", ->(event) {
        window.alert(event.reason)
      })
    end
  end

  prepend_to_head JsErrorHandler

  append_to_head Style, HomeView::Style, LeaderboardView::Style, GameGridView::Style, GameSummaryView::Style
  append_to_head Orma::Record::HealthCheckActionTemplate::Style

  ToHtml.instance_template do
    super do
      h1(SiteHeading) do
        span(SiteHeadingBegin) { "HIT" }
        span(SiteHeadingEnd) { "RACE" }
      end
      yield
    end
  end
end
