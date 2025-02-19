class PlayButtonView
  include Crumble::ContextView
  include IdentifiableView

  element_id PlayButtonViewId
  css_class PlayButton

  def dom_id
    PlayButtonViewId
  end

  style do
    rule PlayButton do
      marginTop 10.px
    end
  end

  template do
    if ctx.session.player_name
      div PlayButton do
        form action: WaitResource.uri_path, method: "POST" do
          button { "Play" }
        end
      end
    end
  end
end
