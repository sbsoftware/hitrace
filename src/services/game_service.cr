class GameService
  def self.create_game(waiting_players : Tuple(WaitingPlayer, WaitingPlayer)) : Game?
    return if waiting_players.any? do |waiting_player|
      next true unless waiting_player.online?

      GamePlayer.where(session_id: waiting_player.session_id).any? do |game_player|
        !game_player.game.finished?
      end
    end

    # TODO: Transaction start
    game = Game.create

    waiting_players.each do |waiting_player|
      GamePlayer.create(game_id: game.id, session_id: waiting_player.session_id, player_name: waiting_player.player_name)
    end

    generate_target_positions(Game::GAME_DURATION.total_seconds.to_u32, game.size_x.value.to_u32, game.size_y.value.to_u32) do |(pos_x, pos_y), i|
      HitTarget.create(game_id: game.id, pos_x: pos_x.to_i, pos_y: pos_y.to_i, delay_ms: 1000 * i.to_i)
    end
    # TODO: Transaction end

    game
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
