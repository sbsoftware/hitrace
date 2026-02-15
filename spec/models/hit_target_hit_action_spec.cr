require "../spec_helper"

describe HitTarget::HitAction do
  describe ".handle" do
    it "rolls back hit writes when score persistence fails" do
      game = Game.create
      user1 = User.create(name: "TxHitP1")
      user2 = User.create(name: "TxHitP2")
      player1 = GamePlayer.create(game_id: game.id, user_id: user1.id)
      GamePlayer.create(game_id: game.id, user_id: user2.id)
      target = HitTarget.create(game_id: game.id, pos_x: 1, pos_y: 1, delay_ms: 0)

      request_ctx = Crumble::Server::TestRequestContext.new(
        method: "POST",
        resource: HitTarget::HitAction.uri_path(target.id)
      )
      request_ctx.session.update!(user_id: user1.id.value)

      ApplicationRecord.db.exec("DROP TRIGGER IF EXISTS fail_game_player_update")
      ApplicationRecord.db.exec <<-SQL
        CREATE TRIGGER fail_game_player_update
        BEFORE UPDATE ON game_players
        WHEN NEW.id = #{player1.id.value}
        BEGIN
          SELECT RAISE(ABORT, 'forced game_player update failure');
        END;
      SQL

      begin
        expect_raises(Orma::DBError, /forced game_player update failure/) do
          HitTarget::HitAction.handle(request_ctx)
        end
      ensure
        ApplicationRecord.db.exec("DROP TRIGGER IF EXISTS fail_game_player_update")
      end

      reloaded_target = HitTarget.find(target.id)
      reloaded_target.hit_at_ms.should be_nil
      reloaded_target.hitting_game_player_id.should be_nil

      GamePlayer.find(player1.id).score.should eq(0)
      HitTargetHit.where(hit_target_id: target.id, game_player_id: player1.id).count.should eq(0)
    end
  end
end
