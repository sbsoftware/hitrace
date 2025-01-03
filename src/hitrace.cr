macro css_class(name)
  class {{name}} < CSS::CSSClass; end
end

macro element_id(name)
  class {{name}} < CSS::ElementId; end
end

macro style(&blk)
  class Style < CSS::Stylesheet
    rules do
      {{blk.body}}
    end
  end
end

macro stimulus_controller(name, &blk)
  class {{name}} < Stimulus::Controller
    {{blk.body}}
  end
end

require "./crumble_server"
