class GameService
  def self.create_game(players : Tuple(WaitingPlayer, WaitingPlayer) | Tuple(RoomPlayer, RoomPlayer), room_id = nil) : Game?
    return if players.any? { |player| !player.online? || player.user.active_game_player }

    ApplicationRecord.transaction do
      game = Game.create(room_id: room_id)

      players.each do |player|
        GamePlayer.create(game_id: game.id, user_id: player.user_id)
      end

      generate_target_positions(Game::GAME_DURATION.total_seconds.to_u32, game.size_x.value.to_u32, game.size_y.value.to_u32) do |(pos_x, pos_y), i|
        HitTarget.create(game_id: game.id, pos_x: pos_x.to_i, pos_y: pos_y.to_i, delay_ms: 1000 * i.to_i)
      end

      game
    end
  end

  def self.generate_target_positions(count : UInt32, size_x : UInt32, size_y : UInt32, &block : (Tuple(UInt32, UInt32), UInt32) -> Nil) : Nil
    i = 0_u32
    last = nil

    while (i < count)
      positions = {rand(1_u32..size_x), rand(1_u32..size_y)}

      next if last && last == positions

      yield positions, i
      last = positions
      i += 1
    end
  end
end
