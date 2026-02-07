class GameSummaryView
  include Crumble::ContextView

  getter game : Game

  css_class GameSummary
  css_class Buttons
  css_class ReactionTimesTable
  css_class HeaderCell
  css_class TargetCell
  css_class ReactionCell
  css_class WinningReaction
  css_class AverageRow

  style do
    rule GameSummary do
      display :flex
      flex_direction :column
      align_items :center
    end

    rule ReactionTimesTable do
      width 100.vw
      max_width 500.px
      margin_top 15.px
      property("border-collapse", "collapse")
    end

    rule HeaderCell do
      padding 8.px
      border 1.px, :solid, :white
      text_align :center
      font_weight :bold
    end

    rule TargetCell do
      padding 6.px
      border 1.px, :solid, :white
      text_align :center
      width 20.percent
    end

    rule ReactionCell do
      padding 6.px
      border 1.px, :solid, :white
      text_align :center
      width 40.percent
    end

    rule WinningReaction do
      background_color rgb(50, 205, 50, alpha: 35.percent)
    end

    rule AverageRow do
      font_weight :bold
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

  private def reaction_time_ms(target : HitTarget, player : GamePlayer) : Int64?
    hit = HitTargetHit.where(hit_target_id: target.id, game_player_id: player.id).first?
    return unless hit

    visible_at_ms = player.target_visible_at(target).to_unix_ms
    hit_at_ms = (Time.unix_ms(hit.hit_at_ms.value) - player.delay_ms.milliseconds).to_unix_ms

    rt = hit_at_ms - visible_at_ms
    rt < 0 ? 0_i64 : rt
  end

  private def avg_reaction_time_ms(targets : Array(HitTarget), player : GamePlayer) : Int64?
    sum = 0_i64
    count = 0_i64

    targets.each do |t|
      if rt = reaction_time_ms(t, player)
        sum += rt
        count += 1
      end
    end

    return if count == 0
    sum // count
  end

  private def format_reaction_time(ms : Int64) : String
    "#{ms}ms"
  end

  ToHtml.instance_template do
    targets = game.hit_targets.to_a.sort_by(&.delay_ms.value)
    players = game.game_players.to_a

    div GameSummary do
      if winner = game.winner
        h1 { "#{winner.player_name} has won!" }
      elsif game.game_players.any? { |gp| gp.score > 0 }
        h1 { "Draw!" }
      else
        h1 { "The game has been aborted!" }
      end

      div Buttons do
        summary_link_button(HomePage.uri_path, "Home")

        if room_id = game.room_id
          summary_link_button(RoomPage.uri_path(room_id), "Back to room")
        else
          play_again_button
        end
      end

      table ReactionTimesTable do
        thead do
          tr do
            th HeaderCell do
              "Target"
            end
            players.each do |player|
              th HeaderCell, player.player_color_class do
                "#{player.player_name} (#{player.score})"
              end
            end
          end
        end

        tbody do
          targets.each do |target|
            times = players.map { |p| reaction_time_ms(target, p) }
            winning = times.compact.min?
            target_number = (target.delay_ms.value // 1000) + 1

            tr do
              td TargetCell do
                target_number.to_s
              end

              times.each do |time|
                td ReactionCell, (WinningReaction if winning && time && time == winning) do
                  format_reaction_time(time) if time
                end
              end
            end
          end

          tr AverageRow do
            td TargetCell do
              "Avg"
            end

            players.each do |player|
              if avg = avg_reaction_time_ms(targets, player)
                td ReactionCell do
                  format_reaction_time(avg)
                end
              else
                td ReactionCell do
                  nil
                end
              end
            end
          end
        end
      end
    end
  end
end
