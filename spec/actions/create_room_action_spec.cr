require "../spec_helper"

describe CreateRoomAction do
  describe ".handle" do
    it "creates a room and assigns the creator as admin" do
      request_ctx = Crumble::Server::TestRequestContext.new(
        method: "POST",
        resource: CreateRoomAction.uri_path
      )
      user = request_ctx.session.ensure_user

      room_count_before = Room.all.count
      room_player_count_before = RoomPlayer.all.count

      CreateRoomAction.handle(request_ctx).should be_true
      request_ctx.response.status_code.should eq(303)

      room = Room.where(name: "#{user.display_name}'s Room").order_by_id!(:desc).first?
      room.should_not be_nil
      created_room = room.not_nil!

      request_ctx.response.headers["Location"].should eq(RoomPage.uri_path(created_room.id))
      RoomPlayer.where(room_id: created_room.id, user_id: user.id, admin: true).count.should eq(1)
      Room.all.count.should eq(room_count_before + 1)
      RoomPlayer.all.count.should eq(room_player_count_before + 1)
    end

    it "rolls back room creation if player creation fails" do
      request_ctx = Crumble::Server::TestRequestContext.new(
        method: "POST",
        resource: CreateRoomAction.uri_path
      )
      user = request_ctx.session.ensure_user

      room_count_before = Room.all.count
      room_player_count_before = RoomPlayer.all.count

      ApplicationRecord.db.exec("DROP TRIGGER IF EXISTS fail_room_player_insert")
      ApplicationRecord.db.exec <<-SQL
        CREATE TRIGGER fail_room_player_insert
        BEFORE INSERT ON room_players
        WHEN NEW.user_id = #{user.id.value}
        BEGIN
          SELECT RAISE(ABORT, 'forced room_player failure');
        END;
      SQL

      begin
        expect_raises(Orma::DBError, /forced room_player failure/) do
          CreateRoomAction.handle(request_ctx)
        end
      ensure
        ApplicationRecord.db.exec("DROP TRIGGER IF EXISTS fail_room_player_insert")
      end

      Room.all.count.should eq(room_count_before)
      RoomPlayer.all.count.should eq(room_player_count_before)
    end
  end
end
