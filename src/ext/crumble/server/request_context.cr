module Crumble::Server
  class RequestContext
    def self.init_session_store
      FileSessionStore.new("./tmp/sessions")
    end

    def room_policy
      RoomPolicy.new(session)
    end
  end
end
