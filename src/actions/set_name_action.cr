class SetNameAction < Crumble::Turbo::Action
  NAME_ATTR = "name"

  def self.action_name : String
    "set_name"
  end

  def controller
    return unless body = ctx.request.body

    name = nil
    HTTP::Params.parse(body.gets_to_end) do |key, value|
      case key
      when NAME_ATTR
        name = value
      end
    end

    return unless name

    ctx.session.update!(player_name: name)

    Template.new(ctx.session).turbo_stream.to_html(ctx.response)
  end

  class Template
    include IdentifiableView

    getter session : Crumble::Server::SessionDecorator

    def initialize(@session); end

    element_id SetNameId

    def dom_id
      SetNameId
    end

    ToHtml.instance_template do
      div do
        form action: SetNameAction.uri_path, method: "POST" do
          input type: :text, name: NAME_ATTR, value: session.player_name
          input type: :submit, value: "OK"
        end
        if session.player_name
          span { "OK" }
        end
      end
    end
  end
end

Crumble::Turbo::ActionRegistry.add(SetNameAction)
