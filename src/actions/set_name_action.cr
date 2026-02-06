class SetNameAction < Crumble::Turbo::Action
  form do
    field name : String
  end

  policy do
    can_view do
      ctx.session.user.try(&.name).nil?
    end

    can_submit do
      ctx.session.user.try(&.name).nil?
    end
  end

  controller do
    # TODO: Move size validation into form as soon as possible
    return unless form.valid? && (name = form.name) && name.size > 0

    ctx.session.ensure_user.update(name: name)
  end

  view do
    template do
      div do
        action_form.to_html do
          input type: :submit, value: "Change Name"
        end
      end
    end
  end
end
