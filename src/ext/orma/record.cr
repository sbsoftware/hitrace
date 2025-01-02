module Orma
  class Record
    macro model_action(name, refreshed_model_template, &blk)
      stimulus_controller {{name.id.stringify.camelcase.id}}Controller do
        targets :submit

        action :submit do
          this.submitTarget.click._call
        end
      end

      class {{name.id.stringify.camelcase.id}}Action < Orma::ModelAction
        @model : {{@type}}?

        def self.action_name : String
          {{name.id.stringify}}
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

        class Template
          getter parent : {{@type}}

          forward_missing_to parent

          def initialize(@parent); end

          def stimulus_controller
            {{name.id.stringify.camelcase.id}}Controller
          end

          ToHtml.instance_template do
            div stimulus_controller do
              form style: "display: none;", action: {{name.id.stringify.camelcase.id}}Action.uri_path(id), method: "POST" do
                input stimulus_controller.submit_target, type: :submit
              end
              div stimulus_controller.submit_action("click") do
                yield
              end
            end
          end
        end

        {{blk.body}}
      end

      def {{name.id.stringify.underscore.id}}_action_template
        {{name.id.stringify.camelcase.id}}Action::Template.new(self)
      end

      Crumble::Turbo::ActionRegistry.add({{@type.name}}::{{name.id.stringify.camelcase.id}}Action)
    end
  end
end
