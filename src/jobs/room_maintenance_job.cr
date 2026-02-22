class RoomMaintenanceJob < RecurringBackgroundJob
  STALE_ROOM_AGE       = 3.minutes
  STALE_CONNECTION_AGE = 60.seconds

  def run_iteration : Bool
    changed = false

    Room.all.find_each do |room|
      unless recent_room?(room)
        room.room_players.each do |room_player|
          next unless stale_room_player?(room_player)

          room_player.destroy
          changed = true
        end

        if room.room_players.empty?
          room.destroy
          changed = true
          next
        end
      end

      next unless room.ready?

      room_players = room.room_players.to_a
      if game = GameService.create_game({room_players[0], room_players[1]}, room.id)
        room.game_id = game.id
        room.last_game_started_at = Time.utc
        room.save
        changed = true
      end
    end

    changed
  end

  private def recent_room?(room : Room) : Bool
    if last_game_at = room.last_game_started_at
      last_game_at > STALE_ROOM_AGE.ago
    else
      false
    end
  end

  private def stale_room_player?(room_player : RoomPlayer) : Bool
    if last_check = room_player.last_connection_check_at
      last_check < STALE_CONNECTION_AGE.ago
    else
      false
    end
  end
end
