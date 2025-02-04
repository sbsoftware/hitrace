class HomeView < Crumble::ContextView
  css_class HomeViewGrid

  style do
    rule HomeViewGrid do
      prop("margin-top", 15.px)
    end

    rule HomeViewGrid > GameGridView::Grid do
      prop("transform", "perspective(500px) rotateX(45deg) translate(0px, -100px)")
      prop("box-shadow", "0px 50px 30px 20px rgba(30, 30, 30, 0.5)")
    end

    rule HomeViewGrid > GameGridView::Cell do
      border 3.px, Solid, White
    end
  end

  template do
    SetNameAction::Template.new(ctx.session)

    RoomListView.new(ctx)

    div HomeViewGrid do
      GameGridView.new(size_x: 5, size_y: 5, targets: [] of HitTarget)
    end
  end
end
