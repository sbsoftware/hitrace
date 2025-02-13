require "./leaderboard_view"

class HomeView
  include Crumble::ContextView

  css_class TopRow
  css_class TopColumn
  css_class HomeViewGrid
  css_class PlayButton

  style do
    rule TopRow do
      display Flex
      width 100.vw
      maxWidth 650.px
    end

    rule TopColumn do
      width 50.percent
      padding 5.px
    end

    rule HomeViewGrid do
      prop("margin-top", 15.px)
    end

    rule HomeViewGrid > GameGridView::Grid do
      prop("transform", "perspective(800px) rotateX(45deg) rotateZ(30deg) rotateY(-15deg) translate(-100px, -100px)")
      prop("box-shadow", "0px 50px 30px 20px rgba(30, 30, 30, 0.5)")
    end

    rule PlayButton do
      marginTop 10.px
    end
  end

  template do
    div TopRow do
      div TopColumn do
        LeaderboardView.new(ctx: ctx)
      end
      div TopColumn do
        SetNameAction::Template.new(ctx.session)

        if ctx.session.player_name
          div PlayButton do
            form action: WaitResource.uri_path, method: "POST" do
              button { "Play" }
            end
          end
        end
      end
    end

    div HomeViewGrid do
      GameGridView.new(size_x: 5, size_y: 5)
    end

    RoomListView.new(ctx: ctx)
  end
end
