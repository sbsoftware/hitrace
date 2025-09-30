class SetNameAction < Crumble::Turbo::Action
  NAME_ATTR = "name"

  form do
    field name : String
  end

  controller do
    return unless body = ctx.request.body

    form = Form.from_www_form(body.gets_to_end)

    # TODO: Move size validation into form as soon as possible
    return unless form.valid? && (name = form.name) && name.size > 0

    ctx.session.ensure_user.update(**form.values)
  end

  view do
    template do
      unless (user = ctx.session.user) && user.name
        div do
          action_form.to_html do
            input type: :submit, value: "Change Name"
          end
        end
      end
    end
  end
end
