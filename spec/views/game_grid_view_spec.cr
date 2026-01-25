require "../spec_helper"

describe GameGridView do
  context "#to_html" do
    it "should render an empty grid" do
      Game.continuous_migration!
      game = Game.create(size_x: 2, size_y: 2)
      targets = [] of HitTarget
      game_player = GamePlayer.new(id: 1_i64, game_id: game.id, user_id: 1_i64)
      view = GameGridView.new(ctx: test_handler_context, size_x: 2, size_y: 2, targets: targets, game_player: game_player)

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
      game = Game.create(size_x: 2, size_y: 2)
      user = User.create
      game_player = GamePlayer.create(game_id: game.id, user_id: user.id)
      target = HitTarget.create(game_id: game.id, pos_x: 1, pos_y: 1, delay_ms: 0)
      view = GameGridView.new(ctx: test_handler_context, size_x: 2, size_y: 2, targets: [target], game_player: game_player)

      actual = view.to_html
      actual.should contain("game-grid-view--target")
      actual.should contain(%(data-controller="game-grid-view--hit-target"))
      actual.should contain(%(/a/hit_target/#{target.id}/hit))
    end
  end
end
