macro css_class(name)
  class {{name}} < CSS::CSSClass; end
end

macro element_id(name)
  class {{name}} < CSS::ElementId; end
end

macro style(&blk)
  class Style < CSS::Stylesheet
    rules do
      {{blk.body}}
    end
  end
end

require "sqlite3"
require "orma"
require "crumble-turbo"
require "./ext/**"
require "./models/*"
require "./policies/**"
require "./actions/**"
require "./services/**"
require "./styles/**"
require "./views/*"
require "./resources/*"
