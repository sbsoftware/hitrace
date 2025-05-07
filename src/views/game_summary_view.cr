class GameSummaryView
  getter game : Game

  def initialize(@game); end

  css_class GameSummary

  style do
    rule GameSummary do
      display Flex
      flexDirection Column
      alignItems Center
    end
  end

  ToHtml.instance_template do
    div GameSummary do
      div style: "display: none;" do
        winner = game.game_players.max_by { |gp| gp.score.value }
      end

      if winner
        h1 { "#{winner.player_name} has won!" }
      elsif game.game_players.any? { |gp| gp.score > 0 }
        h1 { "Draw!" }
      else
        h1 { "The game has been aborted!" }
      end

      game.leaderboard

      p do
        a HomeResource do
          "Home"
        end

        if room_id = game.room_id
          "&nbsp; | &nbsp;"

          a href: RoomResource.uri_path(room_id) do
            "Back to room"
          end
        else
          form action: WaitResource.uri_path, method: "POST" do
            button { "Play again" }
          end
        end
      end
    end
  end
end
