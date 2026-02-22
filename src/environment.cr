macro element_id(name)
  class {{name}} < CSS::ElementId; end
end

require "sqlite3"
require "orma"
require "crumble-turbo"
require "crumble-jobs"

Crumble::Jobs.configure_queue Crumble::Jobs::FileQueue.new(ENV["CRUMBLE_JOBS_QUEUE_ROOT"]? || "./tmp/jobs")

require "./ext/**"
require "./resources/application_resource"
require "./pages/application_page"
require "./models/*"
require "./policies/**"
require "./actions/**"
require "./services/**"
require "./jobs/recurring_background_job"
require "./jobs/**"
require "./styles/**"
require "./views/*"
require "./pages/*"
require "./resources/*"
