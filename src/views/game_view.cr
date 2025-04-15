class GameView
  include Crumble::ContextView

  getter game : Game

  def game_player : GamePlayer
    game.game_players.find! do |gp|
      gp.session_id == ctx.session.id.to_s
    end
  end

  ToHtml.instance_template do
    game_player.time_sync_action_template unless game_player.ready?
    game_player.game_view
  end
end
