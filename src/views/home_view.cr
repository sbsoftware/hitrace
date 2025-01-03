class HomeView < Crumble::ContextView
  template do
    SetNameAction::Template.new(ctx.session)

    ul do
      Game.all.each do |game|
        li do
          a href: GameResource.uri_path(game.id) do
            "Game##{game.id}"
          end
        end
      end
    end

    form action: GameResource.uri_path, method: "POST" do
      input type: :submit, name: "submit", value: "Create Game"
    end
  end
end
