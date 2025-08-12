class User < ApplicationRecord
  column name : String?, unique: true
  column created_at : Time
  column updated_at : Time

  def waiting_player : WaitingPlayer?
    WaitingPlayer.where(user_id: id).first?
  end

  def active_game_player : GamePlayer?
    GamePlayer.where(user_id: id).find do |gp|
      !gp.game.finished?
    end
  end
end
