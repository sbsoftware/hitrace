class GameScoreboardView
  getter game : Game

  def initialize(@game); end

  css_class Scoreboard
  css_class Player
  css_class PlayerName
  css_class PlayerScore

  style do
    rule Scoreboard do
      display Flex
      justifyContent SpaceBetween
      width 100.vw
      maxWidth 500.px
    end

    rule Player do
      display Flex
      justifyContent SpaceBetween
      width 50.percent
      padding 5.px
      prop("border-radius", "5px 5px 0 0")
    end

    rule (Player & ":nth-child(1)") >> PlayerName do
      prop("order", 1)
    end

    rule (Player & ":nth-child(1)") >> PlayerScore do
      prop("order", 2)
    end

    rule (Player & ":nth-child(2)") >> PlayerName do
      prop("order", 2)
    end

    rule (Player & ":nth-child(2)") >> PlayerScore do
      prop("order", 1)
    end
  end

  ToHtml.instance_template do
    div Scoreboard do
      game.game_players.each do |game_player|
        div Player, game_player.player_color_class do
          span PlayerName do
            game_player.player_name
          end
          span PlayerScore do
            game_player.score
          end
        end
      end
    end
  end
end
