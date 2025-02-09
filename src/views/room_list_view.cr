class RoomListView
  include Crumble::ContextView
  include IdentifiableView

  element_id RoomListViewId

  def dom_id
    RoomListViewId
  end

  ToHtml.instance_template do
    if ctx.session.player_name.try(&.size).try(&.>(0))
      ul do
        Room.where({"game_id" => nil}).each do |room|
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
        input type: :submit, name: "submit", value: "Create Room"
      end
    end
  end
end
