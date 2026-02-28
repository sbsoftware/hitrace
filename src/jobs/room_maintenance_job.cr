class RoomMaintenanceJob < RecurringBackgroundJob
  STALE_ROOM_AGE       = 3.minutes
  STALE_CONNECTION_AGE = 60.seconds

  def run_iteration : Bool
    changed = false

    Room.all.find_each do |room|
      if recent_room?(room)
        logger.info { "Skipping stale cleanup for room #{room.id.value}: last game started within #{STALE_ROOM_AGE}" }
      else
        logger.info { "Running stale cleanup for room #{room.id.value}" }
        room.room_players.each do |room_player|
          unless stale_room_player?(room_player)
            logger.info { "Keeping room player #{room_player.id.value} in room #{room.id.value}: connection check still fresh" }
            next
          end

          room_player.destroy
          changed = true
          logger.info { "Removed stale room player #{room_player.id.value} from room #{room.id.value}" }
        end

        if room.room_players.empty?
          room.destroy
          changed = true
          logger.info { "Destroyed empty stale room #{room.id.value}" }
          next
        end
        logger.info { "Room #{room.id.value} kept after cleanup: still has players" }
      end

      unless room.ready?
        logger.info { "Room #{room.id.value} not ready for game start" }
        next
      end

      room_players = room.room_players.to_a
      if game = GameService.create_game({room_players[0], room_players[1]}, room.id)
        room.game_id = game.id
        room.last_game_started_at = Time.utc
        room.save
        changed = true
        logger.info { "Started room game #{game.id.value} for room #{room.id.value}" }
      else
        logger.info do
          "Room #{room.id.value} ready but game creation skipped for players #{room_players[0].id.value}/#{room_players[1].id.value}"
        end
      end
    end

    logger.info { "Room maintenance iteration made no changes" } unless changed
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
