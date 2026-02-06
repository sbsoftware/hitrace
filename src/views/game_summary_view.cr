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

  ToHtml.inline_template :summary_link_button do |path, label|
    a href: path do
      GameButton.to_html { label }
    end
  end

  ToHtml.inline_template :play_again_button do
    form action: WaitResource.uri_path, method: "POST" do
      GameButton.to_html { "Play again" }
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
        summary_link_button(HomePage.uri_path, "Home")

        if room_id = game.room_id
          summary_link_button(RoomPage.uri_path(room_id), "Back to room")
        else
          play_again_button
        end
      end
    end
  end
end
