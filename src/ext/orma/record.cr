module Orma
  class Record
    stimulus_controller GenericModelActionController do
      targets :submit

      action :submit do
        this.submitTarget.click._call
      end
    end

    class GenericModelActionTemplate
      getter action_path : String

      def initialize(@action_path); end

      css_class Inner

      style do
        rule Inner do
          width 100.percent
          height 100.percent
        end
      end

      ToHtml.instance_template do
        div GenericModelActionController do
          form style: "display: none;", action: action_path, method: "POST" do
            input GenericModelActionController.submit_target, type: :submit
          end
          div Inner, GenericModelActionController.submit_action("click") do
            yield
          end
        end
      end
    end

    macro model_action(name, refreshed_model_template, &blk)
      class {{name.id.stringify.camelcase.id}}Action < Orma::ModelAction
        @model : {{@type}}?

        def self.action_name : String
          {{name.id.stringify}}
        end

        def self.action_template(model)
          ::Orma::Record::GenericModelActionTemplate.new(self.uri_path(model.id))
        end

        def self.model_class : {{@type.resolve}}.class
          {{@type.resolve}}
        end

        def model
          @model ||= {{@type.resolve}}.find(model_id)
        end

        def model_template : IdentifiableView
          model.{{refreshed_model_template}}
        end

        {{blk.body}}
      end

      def {{name.id.stringify.underscore.id}}_action_template
        {{name.id.stringify.camelcase.id}}Action.action_template(self)
      end

      Crumble::Turbo::ActionRegistry.add({{@type.name}}::{{name.id.stringify.camelcase.id}}Action)
    end
  end
end
