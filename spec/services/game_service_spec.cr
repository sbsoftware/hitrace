require "../spec_helper"

describe GameService do
  describe ".create_game" do
    it "rolls back all records if target creation fails" do
      user1 = User.create(name: "TxGameServiceP1")
      user2 = User.create(name: "TxGameServiceP2")
      player1 = WaitingPlayer.create(user_id: user1.id, last_connection_check_at: Time.utc)
      player2 = WaitingPlayer.create(user_id: user2.id, last_connection_check_at: Time.utc)

      game_count_before = Game.all.count
      game_player_count_before = GamePlayer.all.count
      target_count_before = HitTarget.all.count

      ApplicationRecord.db.exec("DROP TRIGGER IF EXISTS fail_hit_target_insert")
      ApplicationRecord.db.exec <<-SQL
        CREATE TRIGGER fail_hit_target_insert
        BEFORE INSERT ON hit_targets
        WHEN NEW.delay_ms = 0
        BEGIN
          SELECT RAISE(ABORT, 'forced hit_target failure');
        END;
      SQL

      begin
        expect_raises(Orma::DBError, /forced hit_target failure/) do
          GameService.create_game({player1, player2})
        end
      ensure
        ApplicationRecord.db.exec("DROP TRIGGER IF EXISTS fail_hit_target_insert")
      end

      Game.all.count.should eq(game_count_before)
      GamePlayer.all.count.should eq(game_player_count_before)
      HitTarget.all.count.should eq(target_count_before)
    end
  end
end
