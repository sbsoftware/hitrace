require "./leaderboard_view"
require "./legal_menu_view"

class HomeView
  include Crumble::ContextView

  css_class TopContainer
  css_class TopBox
  css_class HomeViewGrid

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

    rule HomeViewGrid do
      prop("margin-top", 15.px)
      display Flex
      justifyContent Center
    end

    rule HomeViewGrid > GameGridView::Grid do
      prop("transform", "perspective(800px) scale(0.8) rotateX(45deg) rotateZ(30deg) rotateY(-15deg) translate(-30px, -60px)")
      prop("box-shadow", "0px 50px 30px 20px rgba(30, 30, 30, 0.5)")
    end

    media(maxWidth 500.px) do
      rule HomeViewGrid > GameGridView::Grid do
        maxWidth 80.percent
        prop("transform", "perspective(800px) rotateX(45deg) rotateZ(30deg) rotateY(-15deg) translate(10%, -20%)")
      end
    end
  end

  template do
    div TopContainer do
      div TopBox do
        LeaderboardView.new(ctx: ctx)
      end
      div TopBox do
        SetNameAction::Template.new(ctx.session)

        PlayButtonView.new(ctx: ctx)
      end
    end

    div HomeViewGrid do
      GameGridView.new(size_x: 5, size_y: 5)
    end

    # RoomListView.new(ctx: ctx)

    LegalMenuView
  end
end
