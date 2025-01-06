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

    stimulus_controller HealthCheckActionController do
      targets :submit
      values interval: Int

      js_method :connect do
        that = this
        _literal_js(
        <<-JS
        this.timer = setInterval(function() {
          that.submitTarget.click();
        }, this.intervalValue);
        JS
        )
      end

      js_method :disconnect do
        stopInterval(this.timer)
      end
    end

    class HealthCheckActionTemplate
      getter action_path : String
      getter interval : Int32

      def initialize(@action_path, @interval); end

      css_class Form

      style do
        rule Form do
          display None
        end
      end

      ToHtml.instance_template do
        div HealthCheckActionController, HealthCheckActionController.interval_value(interval.to_s) do
          form Form, action: action_path, method: "POST" do
            input HealthCheckActionController.submit_target, type: :submit, value: "Submit"
          end
        end
      end
    end

    macro health_check_action(name, refreshed_model_template, &blk)
      model_action({{name}}, {{refreshed_model_template}}) do
        def self.action_template(model)
          ::Orma::Record::HealthCheckActionTemplate.new(self.uri_path(model.id), interval)
        end

        def self.interval
          2000
        end

        {{blk.body}}
      end
    end
  end
end
