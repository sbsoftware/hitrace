class MatchmakingJob < RecurringBackgroundJob
  def run_iteration : Bool
    game_created = false

    WaitingPlayer.all.to_a.each_slice(2) do |waiting_players|
      next unless waiting_players.size > 1

      if GameService.create_game({waiting_players[0], waiting_players[1]})
        game_created = true
      end
    end

    game_created
  end
end
