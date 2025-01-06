module Crumble::Server
  class RequestContext
    def self.init_session_store
      FileSessionStore.new("./tmp/sessions")
    end

    def game_policy
      GamePolicy.new(session)
    end

    def room_policy
      RoomPolicy.new(session)
    end
  end
end
