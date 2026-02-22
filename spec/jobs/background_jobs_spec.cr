require "../spec_helper"

def create_user(name : String) : User
  User.create(name: "#{name}-#{Random.rand(1_000_000)}")
end

def create_waiting_player(
  user : User,
  *,
  created_at : Time,
  last_connection_check_at : Time?,
) : WaitingPlayer
  waiting_player = WaitingPlayer.create(user_id: user.id, last_connection_check_at: last_connection_check_at)
  waiting_player.update(created_at: created_at, updated_at: created_at)
  WaitingPlayer.find(waiting_player.id)
end

def mark_ready(game_player : GamePlayer) : Nil
  5.times do |index|
    timestamp = index.to_i64
    GamePlayerTimeSync.create(
      game_player_id: game_player.id,
      client_time_ms: timestamp,
      server_time_ms: timestamp
    )
  end
end

describe "background jobs" do
  before_each do
    [
      "hit_target_hits",
      "game_player_time_syncs",
      "hit_targets",
      "game_players",
      "games",
      "room_players",
      "rooms",
      "waiting_players",
      "leaderboard_entrys",
      "users",
    ].each do |table|
      ApplicationRecord.db.exec("DELETE FROM #{table}")
    end

    Crumble::Jobs.set_queue(Crumble::Jobs::InMemoryQueue.new(10_000))
  end

  it "removes offline stale waiting players older than 20 seconds" do
    stale_offline = create_waiting_player(
      create_user("stale-offline"),
      created_at: Time.utc - 2.minutes,
      last_connection_check_at: Time.utc - 2.minutes
    )
    stale_online = create_waiting_player(
      create_user("stale-online"),
      created_at: Time.utc - 2.minutes,
      last_connection_check_at: Time.utc
    )
    fresh_offline = create_waiting_player(
      create_user("fresh-offline"),
      created_at: Time.utc,
      last_connection_check_at: Time.utc - 2.minutes
    )

    WaitlistCleanupJob.new.perform

    WaitingPlayer.where(id: stale_offline.id.value).first?.should be_nil
    WaitingPlayer.where(id: stale_online.id.value).first?.should_not be_nil
    WaitingPlayer.where(id: fresh_offline.id.value).first?.should_not be_nil
  end

  it "pairs waiting players into a game" do
    waiting_player_1 = WaitingPlayer.create(user_id: create_user("match-1").id, last_connection_check_at: Time.utc)
    waiting_player_2 = WaitingPlayer.create(user_id: create_user("match-2").id, last_connection_check_at: Time.utc)

    MatchmakingJob.new.perform

    game = Game.all.order_by_id!(:desc).first?
    game.should_not be_nil

    game_player_user_ids = game.not_nil!.game_players.map { |game_player| game_player.user_id.value }.sort
    game_player_user_ids.should eq([waiting_player_1.user_id.value, waiting_player_2.user_id.value].sort)
  end

  it "removes stale offline room players and destroys empty stale rooms" do
    room = Room.create(name: "Stale room")
    RoomPlayer.create(
      room_id: room.id,
      user_id: create_user("stale-room-player").id,
      last_connection_check_at: Time.utc - 2.minutes
    )

    RoomMaintenanceJob.new.perform

    Room.where(id: room.id.value).first?.should be_nil
    RoomPlayer.where(room_id: room.id.value).count.should eq(0)
  end

  it "starts a game for ready rooms and updates room game metadata" do
    room = Room.create(name: "Ready room")
    room_player_1 = RoomPlayer.create(
      room_id: room.id,
      user_id: create_user("ready-room-1").id,
      ready: true,
      last_connection_check_at: Time.utc
    )
    room_player_2 = RoomPlayer.create(
      room_id: room.id,
      user_id: create_user("ready-room-2").id,
      ready: true,
      last_connection_check_at: Time.utc
    )

    RoomMaintenanceJob.new.perform

    updated_room = Room.find(room.id)
    updated_room.game_id.should_not be_nil
    updated_room.last_game_started_at.should_not be_nil

    game = Game.find(updated_room.game_id.not_nil!)
    game.room_id.should_not be_nil
    game.room_id.not_nil!.value.should eq(room.id.value)
    game.game_players.map { |game_player| game_player.user_id.value }.sort.should eq(
      [room_player_1.user_id.value, room_player_2.user_id.value].sort
    )
  end

  it "starts games when both players are ready" do
    game = Game.create
    game_player_1 = GamePlayer.create(game_id: game.id, user_id: create_user("ready-game-1").id)
    game_player_2 = GamePlayer.create(game_id: game.id, user_id: create_user("ready-game-2").id)

    mark_ready(game_player_1)
    mark_ready(game_player_2)

    GameProcessingJob.new.perform

    updated_game = Game.find(game.id)
    updated_game.started_at.should_not be_nil
    updated_game.processing_completed.value.should be_false
  end

  it "marks games older than 30 seconds as started at created_at when players are not ready" do
    game = Game.create(created_at: Time.utc - 2.minutes)
    GamePlayer.create(game_id: game.id, user_id: create_user("timeout-game-1").id)
    GamePlayer.create(game_id: game.id, user_id: create_user("timeout-game-2").id)

    GameProcessingJob.new.perform

    updated_game = Game.find(game.id)
    updated_game.started_at.should_not be_nil
    updated_game.started_at.not_nil!.value.should eq(updated_game.created_at.value)
  end

  it "processes finished games, updates leaderboard entries, resets rooms, and marks completion" do
    room = Room.create(name: "Finished game room")
    room_player_1 = RoomPlayer.create(
      room_id: room.id,
      user_id: create_user("finished-room-1").id,
      ready: true,
      last_connection_check_at: Time.utc
    )
    room_player_2 = RoomPlayer.create(
      room_id: room.id,
      user_id: create_user("finished-room-2").id,
      ready: true,
      last_connection_check_at: Time.utc
    )

    game = Game.create(room_id: room.id, started_at: Time.utc - 2.minutes)
    winning_game_player = GamePlayer.create(game_id: game.id, user_id: room_player_1.user_id.value, score: 5)
    GamePlayer.create(game_id: game.id, user_id: room_player_2.user_id.value, score: 3)

    room.update(game_id: game.id, last_game_started_at: Time.utc)
    existing_entry = LeaderboardEntry.create(user_id: winning_game_player.user_id.value, games_won: 2_i64)

    GameProcessingJob.new.perform

    updated_game = Game.find(game.id)
    updated_game.processing_completed.value.should be_true

    updated_room = Room.find(room.id)
    updated_room.game_id.should be_nil
    updated_room.room_players.each do |room_player|
      room_player.ready.value.should be_false
    end

    leaderboard_entry = LeaderboardEntry.find(existing_entry.id)
    leaderboard_entry.games_won.value.should eq(3_i64)
  end
end
