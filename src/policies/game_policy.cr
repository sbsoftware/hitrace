class GamePolicy
  getter session : Crumble::Server::SessionDecorator

  def initialize(@session); end

  def show?(game)
    return false unless user = session.user

    game.game_players.any? do |game_player|
      game_player.user_id == user.id
    end
  end
end
