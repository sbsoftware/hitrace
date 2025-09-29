class GameView
  include Crumble::ContextView

  getter game_player : GamePlayer

  ToHtml.instance_template do
    game_player.time_sync_action_template(ctx) unless game_player.ready?
    game_player.game_view.renderer(ctx)
  end
end
