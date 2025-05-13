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

  css_class TopMenu
  css_class SiteHeading
  css_class SiteHeadingBegin
  css_class SiteHeadingEnd
  css_class ContentLayout
  css_class MainContent
  css_class HomePageAd

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
      minHeight 100.percent
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

    rule TopMenu do
      position Absolute
      top 0
      prop("right", "0")
      padding 10.px
    end

    rule SiteHeading do
      fontSize "40pt"
      fontFamily "Rubik Spray Paint"
      fontWeight Normal
    end

    rule SiteHeading >> a do
      textDecoration None
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

    rule ContentLayout do
      display Flex
      justifyContent SpaceBetween
    end

    media(maxWidth 800.px) do
      rule HomePageAd do
        display None
      end
    end
  end

  class JsErrorHandler < JS::Code
    def_to_js do
      params = URLSearchParams.new(window.location.search)

      if params.get("debug") == "true"
        self.addEventListener("error", ->(event) {
          window.alert(event.message)
        })
        self.addEventListener("unhandledrejection", ->(event) {
          window.alert(event.reason)
        })
      end
    end
  end

  prepend_to_head JsErrorHandler

  class ESShim
    ToHtml.class_template do
      script src: "https://cdnjs.cloudflare.com/ajax/libs/es5-shim/4.5.15/es5-shim.min.js"
      script src: "https://cdnjs.cloudflare.com/ajax/libs/es6-shim/0.35.8/es6-shim.min.js"
    end
  end

  prepend_to_head ESShim

  append_to_head Style, ApplicationStyle, HomeView::Style, LegalMenuView::Style, PlayButtonView::Style, LeaderboardView::Style, GameGridView::Style, GameSummaryView::Style
  append_to_head GamePlayer::Style
  append_to_head Orma::Record::HealthCheckActionTemplate::Style
  append_to_head GamePlayer::TimeSyncTemplate::Style
  append_to_head GameScoreboardView::Style

  class AdsByGoogle
    ToHtml.class_template do
      script async: true, src: "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-5259491325832394", crossorigin: "anonymous"
    end
  end

  append_to_head AdsByGoogle

  ToHtml.instance_template do
    super do
      div TopMenu do
        a href: "https://discord.gg/2cbStUzb", target: "_blank" do
          "Join our Discord"
        end
      end

      h1(SiteHeading) do
        a HomeResource do
          span(SiteHeadingBegin) { "HIT" }
          span(SiteHeadingEnd) { "RACE" }
        end
      end
      div ContentLayout do
        div MainContent do
          yield
        end
        div HomePageAd do
          ins class: "adsbygoogle", style: "display:block", data_ad_client: "ca-pub-5259491325832394", data_ad_slot: "1032697835", data_ad_format: "auto", data_full_width_responsive: "true"
          script do
           "(adsbygoogle = window.adsbygoogle || []).push({});"
          end
        end
      end
    end
  end
end
