require "log"

class RoomMaintenanceJob < Crumble::Jobs::Job
  STALE_ROOM_AGE       = 3.minutes
  STALE_CONNECTION_AGE = 60.seconds
  params room_id : Int64

  def perform : Nil
    unless room = Room.where(id: room_id).first?
      logger.info { "Skipping room maintenance: room #{room_id} not found" }
      return
    end

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
        logger.info { "Removed stale room player #{room_player.id.value} from room #{room.id.value}" }
      end

      if room.room_players.empty?
        room.destroy
        logger.info { "Destroyed empty stale room #{room.id.value}" }
        return
      end
      logger.info { "Room #{room.id.value} kept after cleanup: still has players" }
    end

    unless room.ready?
      logger.info { "Room #{room.id.value} not ready for game start" }
      return
    end

    room_players = room.room_players.to_a
    if game = GameService.create_game({room_players[0], room_players[1]}, room.id)
      room.game_id = game.id
      room.last_game_started_at = Time.utc
      room.save
      logger.info { "Started room game #{game.id.value} for room #{room.id.value}" }
      BackgroundJobs.enqueue_game_processing(game.id.value, delay: GameProcessingJob::GAME_START_TIMEOUT)
      BackgroundJobs.enqueue_room_maintenance(room.id.value, delay: STALE_ROOM_AGE)
      return
    end

    logger.info { "Room #{room.id.value} ready but game creation skipped for players #{room_players[0].id.value}/#{room_players[1].id.value}" }
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

  private def logger : Log
    Log.for(self.class.job_name)
  end
end
