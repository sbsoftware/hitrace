class GamePolicy
  getter session : Crumble::Server::SessionDecorator

  def initialize(@session); end

  def show?(game)
    game.game_players.any? do |game_player|
      game_player.session_id == session.id.to_s
    end
  end
end
