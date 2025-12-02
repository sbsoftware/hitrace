class GameScoreboardView
  getter game : Game

  def initialize(@game); end

  css_class Scoreboard
  css_class Player
  css_class PlayerName
  css_class PlayerScore

  style do
    rule Scoreboard do
      display :flex
      justify_content :space_between
      width 100.vw
      max_width 500.px
    end

    rule Player do
      display :flex
      justify_content :space_between
      width 50.percent
      padding 5.px
      border_radius 5.px, 5.px, 0, 0
    end

    rule (Player && ":nth-child(1)") > PlayerName do
      order 1
    end

    rule (Player && ":nth-child(1)") > PlayerScore do
      order 2
    end

    rule (Player && ":nth-child(2)") > PlayerName do
      order 2
    end

    rule (Player && ":nth-child(2)") > PlayerScore do
      order 1
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
