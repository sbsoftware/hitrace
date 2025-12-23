macro element_id(name)
  class {{name}} < CSS::ElementId; end
end

require "sqlite3"
require "orma"
require "crumble-turbo"
require "./ext/**"
require "./resources/application_resource"
require "./models/*"
require "./policies/**"
require "./actions/**"
require "./services/**"
require "./styles/**"
require "./views/*"
require "./pages/*"
require "./resources/*"
