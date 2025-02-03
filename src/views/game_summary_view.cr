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
      end

      game.leaderboard

      p do
        a HomeResource do
          "Home"
        end

        "&nbsp; | &nbsp;"

        if room_id = game.room_id
          a href: RoomResource.uri_path(room_id) do
            "Back to room"
          end
        end
      end
    end
  end
end
