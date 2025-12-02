class GameSummaryView
  include Crumble::ContextView

  getter game : Game

  css_class GameSummary
  css_class Buttons

  style do
    rule GameSummary do
      display :flex
      flex_direction :column
      align_items :center
    end

    rule Buttons do
      display :flex
      justify_content :center
      gap 20.px
      margin_top 20.px
    end
  end

  ToHtml.instance_template do
    div GameSummary do
      if winner = game.winner
        h1 { "#{winner.player_name} has won!" }
      elsif game.game_players.any? { |gp| gp.score > 0 }
        h1 { "Draw!" }
      else
        h1 { "The game has been aborted!" }
      end

      game.leaderboard.renderer(ctx)

      div Buttons do
        a HomeResource do
          GameButton.to_html { "Home" }
        end

        if room_id = game.room_id
          a href: RoomResource.uri_path(room_id) do
            GameButton.to_html { "Back to room" }
          end
        else
          form action: WaitResource.uri_path, method: "POST" do
            GameButton.to_html { "Play again" }
          end
        end
      end
    end
  end
end
