class GameService
  def self.create_game(waiting_players : Tuple(WaitingPlayer, WaitingPlayer)) : Game?
    return if waiting_players.any? do |waiting_player|
      next true unless waiting_player.online?

      GamePlayer.where({"session_id" => waiting_player.session_id}).any? do |game_player|
        !game_player.game.finished?
      end
    end

    # TODO: Transaction start
    game = Game.create

    waiting_players.each do |waiting_player|
      GamePlayer.create(game_id: game.id, session_id: waiting_player.session_id, player_name: waiting_player.player_name)
      waiting_player.destroy
    end

    Game::GAME_DURATION.total_seconds.to_i.times do |i|
      HitTarget.create(game_id: game.id, pos_x: rand(1..game.size_x.value), pos_y: rand(1..game.size_y.value), delay_ms: 1000 * i)
    end
    # TODO: Transaction end

    game
  end
end
