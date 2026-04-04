class MatchmakingJob < Crumble::Jobs::Job
  params waiting_player_id : Int64

  def perform : Nil
    unless waiting_player = WaitingPlayer.where(id: waiting_player_id).first?
      return
    end
    unless waiting_player.online?
      return
    end
    if waiting_player.user.active_game_player
      return
    end

    unless opponent = WaitingPlayer.all.order_by_id!.find do |player|
             player.id != waiting_player.id && player.online? && player.user.active_game_player.nil?
           end
      return
    end

    if game = GameService.create_game({waiting_player, opponent})
      BackgroundJobs.enqueue_game_processing(game.id.value, delay: GameProcessingJob::GAME_START_TIMEOUT)
    end
  end
end
