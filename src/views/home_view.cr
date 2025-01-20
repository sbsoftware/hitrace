class HomeView < Crumble::ContextView
  template do
    SetNameAction::Template.new(ctx.session)

    RoomListView.new(ctx)
  end
end
