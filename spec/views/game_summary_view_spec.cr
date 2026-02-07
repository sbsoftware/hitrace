require "../spec_helper"

describe GameSummaryView do
  context "#to_html" do
    it "renders reaction times per target (with winner highlight) and averages" do
      start = Time.utc(2020, 1, 1, 0, 0, 0)
      game = Game.create(started_at: start)

      user1 = User.create
      user2 = User.create
      player1 = GamePlayer.create(game_id: game.id, user_id: user1.id, score: 1)
      player2 = GamePlayer.create(game_id: game.id, user_id: user2.id, score: 1)

      target1 = HitTarget.create(game_id: game.id, pos_x: 1, pos_y: 1, delay_ms: 0)
      target2 = HitTarget.create(game_id: game.id, pos_x: 1, pos_y: 2, delay_ms: 1000)

      HitTargetHit.create(hit_target_id: target1.id, game_player_id: player1.id, hit_at_ms: (start + 200.milliseconds).to_unix_ms)
      HitTargetHit.create(hit_target_id: target1.id, game_player_id: player2.id, hit_at_ms: (start + 300.milliseconds).to_unix_ms)
      HitTargetHit.create(hit_target_id: target2.id, game_player_id: player2.id, hit_at_ms: (start + 1500.milliseconds).to_unix_ms)

      html = GameSummaryView.new(ctx: test_handler_context, game: game).to_html.squish

      html.should contain(%(<table class="game-summary-view--reaction-times-table">))
      html.should contain("200ms")
      html.should contain("300ms")
      html.should contain("500ms")
      html.should contain("Avg")
      html.should contain("400ms")

      html.should contain(%(game-summary-view--winning-reaction">200ms))

      # Target 2: player 1 didn't hit, player 2 won (only hit)
      html.should contain(%(<td class="game-summary-view--target-cell">2</td><td class="game-summary-view--reaction-cell"></td><td class="game-summary-view--reaction-cell game-summary-view--winning-reaction">500ms</td>))
    end

    it "computes reaction times in the client's time coordinate (delay compensated)" do
      start = Time.utc(2020, 1, 1, 0, 0, 0)
      game = Game.create(started_at: start)

      user1 = User.create
      user2 = User.create
      player1 = GamePlayer.create(game_id: game.id, user_id: user1.id, score: 0)
      _player2 = GamePlayer.create(game_id: game.id, user_id: user2.id, score: 0)

      # Force a non-zero delay_ms for player 1.
      5.times do |i|
        GamePlayerTimeSync.create(game_player_id: player1.id, client_time_ms: 900_i64 + i, server_time_ms: 1000_i64 + i)
      end

      target = HitTarget.create(game_id: game.id, pos_x: 1, pos_y: 1, delay_ms: 0)
      HitTargetHit.create(hit_target_id: target.id, game_player_id: player1.id, hit_at_ms: (start + 200.milliseconds).to_unix_ms)

      html = GameSummaryView.new(ctx: test_handler_context, game: game).to_html
      html.should contain("200ms")
      html.should_not contain("300ms")
    end
  end
end
