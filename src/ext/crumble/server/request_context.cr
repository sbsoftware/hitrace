module Crumble::Server
  class RequestContext
    def self.init_session_store
      FileSessionStore.new("./tmp/sessions")
    end

    def session_cookie_max_age
      3600.days
    end

    def game_policy
      GamePolicy.new(session)
    end

    def room_policy
      RoomPolicy.new(session)
    end
  end
end
