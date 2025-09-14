require "./leaderboard_view"
require "./legal_menu_view"

class HomeView
  include Crumble::ContextView

  css_class TopContainer
  css_class TopBox
  css_class HomeViewGrid
  css_class PlayButtonContainer
  css_class GameHint

  style do
    rule TopContainer do
      display Flex
      flexDirection ColumnReverse
      alignItems Center
      width 100.vw
      maxWidth 650.px
    end

    rule TopBox do
      display Flex
      flexDirection Column
      justifyContent Center
      alignItems Center
      width 80.percent
      padding 5.px
      marginTop 10.px
    end

    rule PlayButtonContainer do
      display Flex
      justifyContent SpaceBetween
      prop("gap", 20.px)
    end

    rule GameHint do
      padding 0, 5.px
      display Flex
      alignItems Center
    end

    rule HomeViewGrid do
      prop("margin-top", 15.px)
      display Flex
      justifyContent Center
    end

    rule HomeViewGrid > GameGridView::Grid do
      prop("transform", "perspective(800px) scale(0.6) translate(0, -120px) rotateX(35deg) rotateZ(28deg) rotateY(-15deg) translate(-40px, -60px)")
      prop("box-shadow", "0px 50px 30px 20px rgba(30, 30, 30, 0.5)")
    end
  end

  template do
    div TopContainer do
      div TopBox do
        LeaderboardView.new(ctx: ctx)
      end
      div TopBox do
        SetNameAction.new(ctx).action_template

        div PlayButtonContainer do
          span GameHint do
            "Hit the target tiles faster than your opponent!"
          end
          PlayButtonView.new(ctx: ctx)
        end
      end
    end

    div HomeViewGrid do
      GameGridView.new(size_x: 5, size_y: 5)
    end

    # RoomListView.new(ctx: ctx)

    LegalMenuView
  end
end
