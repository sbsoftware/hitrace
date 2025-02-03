class ApplicationLayout
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

  ToHtml.class_template do
    doctype "html"
    html do
      head do
        title { "Hitrace" }
        meta charset: "utf-8", name: "viewport", content: "width=device-width, initial-scale=1.0"
        link Style
        link Game::Style
        link GameSummaryView::Style
        link Orma::Record::GenericModelActionTemplate::Style
        link Orma::Record::HealthCheckActionTemplate::Style
        script src: "https://unpkg.com/@hotwired/turbo@8.0.4/dist/turbo.es2017-umd.js"
        script Crumble::StimulusControllers
        style do
          "@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@100..900&family=Rubik+Spray+Paint&display=swap');"
        end
      end
      body Crumble::Turbo::ModelTemplateRefreshController do
        h1(SiteHeading) do
          span(SiteHeadingBegin) { "HIT" }
          span(SiteHeadingEnd) { "RACE" }
        end
        yield
      end
    end
  end
end
