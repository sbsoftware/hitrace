class HomeView < Crumble::ContextView
  template do
    SetNameAction::Template.new(ctx.session)

    ul do
      Room.all.each do |room|
        li do
          "#{room.name} (#{room.room_players.count})"
          room.join_action_template.to_html do
            button { "Join" }
          end
        end
      end
    end

    form action: RoomResource.uri_path, method: "POST" do
      input type: :text, name: "name"
      input type: :submit, name: "submit", value: "Create Game"
    end
  end
end
