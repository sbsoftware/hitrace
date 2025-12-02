require "./leaderboard_view"
require "./legal_menu_view"

class HomeView
  include Crumble::ContextView

  css_class TopContainer
  css_class TopBox
  css_class HomeViewGrid
  css_class PlayButtonContainer
  css_class GameHint
  css_class CreateRoomButtonWrapper

  style do
    rule TopContainer do
      display :flex
      flex_direction :column_reverse
      align_items :center
      width 100.vw
      max_width 650.px
    end

    rule TopBox do
      display :flex
      flex_direction :column
      justify_content :center
      align_items :center
      width 80.percent
      padding 5.px
      margin_top 10.px
    end

    rule PlayButtonContainer do
      margin_top 20.px
      display :flex
      justify_content :space_between
      gap 20.px
      align_items :center
    end

    rule GameHint do
      padding 0, 5.px
      display :flex
      align_items :center
      flex_shrink 2
    end

    rule HomeViewGrid do
      margin_top 15.px
      display :flex
      justify_content :center
    end

    rule HomeViewGrid > GameGridView::Grid do
      transform(
        perspective(800.px),
        scale(0.6),
        translate(0, -120.px),
        rotate_x(35.deg),
        rotate_z(28.deg),
        rotate_y(-15.deg),
        translate(-40.px, -60.px)
      )
      box_shadow 0.px, 50.px, 30.px, 20.px, rgb(30, 30, 30, alpha: 50.percent)
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
          PlayButtonView
          span CreateRoomButtonWrapper do
            CreateRoomAction.new(ctx).action_template
          end
        end
      end
    end

    div HomeViewGrid do
      GameGridView.new(ctx: ctx, size_x: 5, size_y: 5)
    end

    LegalMenuView
  end
end
