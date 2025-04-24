require "../spec_helper"

describe GameGridView do
  context "#to_html" do
    it "should render an empty grid" do
      Game.continuous_migration!
      game = Game.create(size_x: 2, size_y: 2)
      targets = [] of HitTarget
      game_player = GamePlayer.new(id: 1_i64, game_id: game.id, player_name: "Tester", session_id: "abcdef12345")
      view = GameGridView.new(size_x: 2, size_y: 2, targets: targets, game_player: game_player)

      expected = <<-HTML.squish
      <div class="game-grid-view--grid">
        <div class="game-grid-view--row">
          <div class="game-grid-view--cell"></div>
          <div class="game-grid-view--cell"></div>
        </div>
        <div class="game-grid-view--row">
          <div class="game-grid-view--cell"></div>
          <div class="game-grid-view--cell"></div>
        </div>
      </div>
      HTML

      actual = view.to_html
      actual.should eq(expected)
    end

    it "should render a grid with targets" do
      # This doesn't work anymore after HIT-31
      # Maybe we need timecop.cr
      pending!

      # Nanoseconds are ignored on Sqlite
      game = Game.create(size_x: 2, size_y: 2, started_at: Time.utc(2025, 4, 23, 21, 55, 0, nanosecond: 900000000))
      game_player = GamePlayer.create(game_id: game.id, player_name: "Tester", session_id: "abcdef12345")
      other_game_player = GamePlayer.create(game_id: game.id, player_name: "Toster", session_id: "xyzwww12345")
      targets = [
        HitTarget.new(id: 1_i64, game_id: game.id, pos_x: 1, pos_y: 1, delay_ms: 1000, hit_at_ms: Time.utc(2025, 4, 23, 21, 55, 1, nanosecond: 600000000).to_unix_ms, hitting_game_player_id: game_player.id)
      ]
      GamePlayerTimeSync.create(game_player_id: game_player.id, client_time_ms: Time.utc(2025, 4, 23, 21, 52, 33, nanosecond: 500000000).to_unix_ms, server_time_ms: Time.utc(2025, 4, 23, 21, 52, 33, nanosecond: 600000000).to_unix_ms)
      view = GameGridView.new(size_x: 2, size_y: 2, targets: targets, game_player: game_player)

      expected = <<-HTML.squish
      <div class="game-grid-view--grid">
        <div class="game-grid-view--row">
          <div class="game-grid-view--cell">
            <div class="game-grid-view--target game-grid-view--hidden-target game-player--player-color1" data-controller="game-grid-view--hit-target" data-game-grid-view--hit-target-visible-at-value="1745445300900" data-game-grid-view--hit-target-visible-until-value="1745445302000">
              <div data-controller="orma--model-action--generic-model-action">
                <form class="crumble--turbo--action--form-template--hidden" action="/a/hit_target/1/hit" method="POST">
                  <input data-orma--model-action--generic-model-action-target="submit" type="submit">
                </form>
                <div class="orma--model-action--generic-model-action-template--inner" data-action="click->orma--model-action--generic-model-action#submit"></div>
              </div>
            </div>
          </div>
          <div class="game-grid-view--cell"></div>
        </div>
        <div class="game-grid-view--row">
          <div class="game-grid-view--cell"></div>
          <div class="game-grid-view--cell"></div>
        </div>
      </div>
      HTML

      actual = view.to_html
      actual.should eq(expected)
    end
  end
end
