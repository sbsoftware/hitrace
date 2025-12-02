class LeaderboardView
  include Crumble::ContextView

  css_class Leaderboard
  css_class Entry

  style do
    rule Leaderboard do
      width 100.percent
      border 1.px, :solid, :white
      border_radius 5.px
      padding 5.px
      box_sizing :border_box
    end

    rule Entry do
      display :flex
      justify_content :space_between
    end
  end

  template do
    div Leaderboard do
      div Entry do
        span { "Leaderboard" }
        span { "Wins" }
      end
      hr
      LeaderboardEntry.all.to_a.sort_by(&.games_won.value.*(-1)).first(5).each do |entry|
        div Entry do
          span { entry.player_name }
          span { entry.games_won }
        end
      end
    end
  end
end
