class PlayButtonView
  include Crumble::ContextView
  include IdentifiableView

  element_id PlayButtonViewId
  css_class PlayButton

  def dom_id
    PlayButtonViewId
  end

  style do
    rule PlayButton >> button do
      prop("background", "transparent")
      color White
      border 1.px, Solid, White
      prop("border-radius", 5.px)
      prop("box-shadow", "0px 0px 2px 1px rgba(0, 255, 0, 0.7)")
      padding 10.px
      fontSize 18.px
      fontFamily "Outfit"
      fontWeight Bold
    end
  end

  template do
    if (user = ctx.session.user) && user.name.try(&.size.>(0))
      div PlayButton do
        form action: WaitResource.uri_path, method: "POST" do
          button { "Play" }
        end
      end
    end
  end
end
