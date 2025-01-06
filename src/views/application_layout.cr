class ApplicationLayout
  ToHtml.class_template do
    doctype "html"
    html do
      head do
        title { "Hitrace" }
        link Game::Style
        link Orma::Record::GenericModelActionTemplate::Style
        link Orma::Record::HealthCheckActionTemplate::Style
        script src: "https://unpkg.com/@hotwired/turbo@8.0.4/dist/turbo.es2017-umd.js"
        script Crumble::StimulusControllers
      end
      body Crumble::Turbo::ModelTemplateRefreshController do
        yield
      end
    end
  end
end
