class MatchmakingJob < RecurringBackgroundJob
  def run_iteration : Bool
    game_created = false

    if WaitingPlayer.all.count < 2
      logger.debug { "Skipping matchmaking: fewer than two waiting players" }
      return false
    end

    WaitingPlayer.all.to_a.each_slice(2) do |waiting_players|
      if waiting_players.size < 2
        logger.debug { "Skipping unmatched waiting player #{waiting_players[0].id.value}" }
        next
      end

      if game = GameService.create_game({waiting_players[0], waiting_players[1]})
        game_created = true
        logger.info do
          "Created game #{game.id.value} from waiting players #{waiting_players[0].id.value} and #{waiting_players[1].id.value}"
        end
      else
        logger.debug do
          "Skipped waiting pair #{waiting_players[0].id.value}/#{waiting_players[1].id.value}: pair not eligible for game creation"
        end
      end
    end

    logger.debug { "Matchmaking iteration created no games" } unless game_created
    game_created
  end
end
