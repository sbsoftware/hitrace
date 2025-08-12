class SetNameAction < Crumble::Turbo::Action
  NAME_ATTR = "name"

  def self.action_name : String
    "set_name"
  end

  class Form < Crumble::Form
    field name : String
  end

  def controller
    return unless body = ctx.request.body

    form = Form.from_www_form(body.gets_to_end)

    # TODO: Move size validation into form as soon as possible
    return unless form.valid? && (name = form.name) && name.size > 0

    ctx.session.ensure_user.update(**form.values)

    Template.new(ctx.session).turbo_stream.to_html(ctx.response)
    PlayButtonView.new(ctx: ctx).turbo_stream.to_html(ctx.response)
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
      unless (user = session.user) && user.name
        div do
          form action: SetNameAction.uri_path, method: "POST" do
            input type: :text, name: NAME_ATTR, placeholder: "Player Name"
            input type: :submit, value: "Change Name"
          end
        end
      end
    end
  end
end

Crumble::Turbo::ActionRegistry.add(SetNameAction)
