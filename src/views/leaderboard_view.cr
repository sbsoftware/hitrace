class LeaderboardView
  include Crumble::ContextView

  css_class Leaderboard
  css_class Entry

  style do
    rule Leaderboard do
      width 100.percent
      border 1.px, Solid, White
      prop("border-radius", 5.px)
      padding 5.px
      boxSizing BorderBox
    end

    rule Entry do
      display Flex
      justifyContent SpaceBetween
    end
  end

  template do
    div Leaderboard do
      div Entry do
        span { "Leaderboard" }
        span { "Wins" }
      end
      hr
      LeaderboardEntry.all.to_a.sort_by(&.games_won.value).last(5).each do |entry|
        div Entry do
          span { entry.player_name }
          span { entry.games_won }
        end
      end
    end
  end
end
