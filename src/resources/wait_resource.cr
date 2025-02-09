class WaitResource < ApplicationResource
  def index
    unless player = WaitingPlayer.where({"session_id" => ctx.session.id.to_s}).first?
      redirect HomeResource.uri_path
    end

    render WaitView.new(ctx: ctx, waiting_player: player)
  end

  def create
    unless player_name = ctx.session.player_name
      redirect HomeResource.uri_path
      return
    end

    unless WaitingPlayer.where({"session_id" => ctx.session.id.to_s}).first?
      WaitingPlayer.create(session_id: ctx.session.id.to_s, player_name: player_name)
    end

    redirect WaitResource.uri_path
  end
end
