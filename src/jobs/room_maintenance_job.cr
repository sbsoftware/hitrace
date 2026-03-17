class RoomMaintenanceJob < Crumble::Jobs::Job
  STALE_ROOM_AGE       = 3.minutes
  STALE_CONNECTION_AGE = 60.seconds
  params room_id : Int64

  def perform : Nil
    unless room = Room.where(id: room_id).first?
      return
    end

    unless recent_room?(room)
      room.room_players.each do |room_player|
        next unless stale_room_player?(room_player)

        room_player.destroy
      end

      if room.room_players.empty?
        room.destroy
        return
      end
    end

    return unless room.ready?

    room_players = room.room_players.to_a
    if game = GameService.create_game({room_players[0], room_players[1]}, room.id)
      room.game_id = game.id
      room.last_game_started_at = Time.utc
      room.save
      BackgroundJobs.enqueue_game_processing(game.id.value, delay: GameProcessingJob::GAME_START_TIMEOUT)
      BackgroundJobs.enqueue_room_maintenance(room.id.value, delay: STALE_ROOM_AGE)
    end
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
