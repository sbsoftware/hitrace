require "./application_record"

# Stores the time a specific player hit a specific target.
# This is separate from `HitTarget#hit_at_ms`, which tracks the first (winning) hit.
class HitTargetHit < ApplicationRecord
  column hit_target_id : Int64
  column game_player_id : Int64
  column hit_at_ms : Int64

  getter hit_target : HitTarget do
    HitTarget.find(hit_target_id)
  end

  getter game_player : GamePlayer do
    GamePlayer.find(game_player_id)
  end
end
