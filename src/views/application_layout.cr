class ApplicationLayout < ToHtml::Layout
  include Crumble::ContextView

  css_class SiteHeading
  css_class SiteHeadingBegin
  css_class SiteHeadingEnd

  style do
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

  class FontInclude
    ToHtml.class_template do
      style do
        "@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@100..900&family=Rubik+Spray+Paint&display=swap');"
      end
    end
  end

  add_to_head Style, HomeView::Style, GameGridView::Style, GameSummaryView::Style
  add_to_head FontInclude
  add_to_head Orma::Record::HealthCheckActionTemplate::Style

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
