require "log"

class MatchmakingJob < Crumble::Jobs::Job
  params waiting_player_id : Int64

  def perform : Nil
    unless waiting_player = WaitingPlayer.where(id: waiting_player_id).first?
      logger.info { "Skipping matchmaking: waiting player #{waiting_player_id} not found" }
      return
    end
    unless waiting_player.online?
      logger.info { "Skipping matchmaking for waiting player #{waiting_player.id.value}: player is offline" }
      return
    end
    if waiting_player.user.active_game_player
      logger.info { "Skipping matchmaking for waiting player #{waiting_player.id.value}: already in active game" }
      return
    end

    unless opponent = WaitingPlayer.all.order_by_id!.find do |player|
             player.id != waiting_player.id && player.online? && player.user.active_game_player.nil?
           end
      logger.info { "Skipping matchmaking for waiting player #{waiting_player.id.value}: no opponent available" }
      return
    end

    if game = GameService.create_game({waiting_player, opponent})
      logger.info { "Created game #{game.id.value} from waiting players #{waiting_player.id.value} and #{opponent.id.value}" }
      BackgroundJobs.enqueue_game_processing(game.id.value, delay: GameProcessingJob::GAME_START_TIMEOUT)
      return
    end

    logger.info { "Skipped waiting pair #{waiting_player.id.value}/#{opponent.id.value}: pair not eligible for game creation" }
  end

  private def logger : Log
    Log.for(self.class.job_name)
  end
end
