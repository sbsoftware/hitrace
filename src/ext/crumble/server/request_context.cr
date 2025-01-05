module Crumble::Server
  class RequestContext
    def self.init_session_store
      FileSessionStore.new("./tmp/sessions")
    end
  end
end
