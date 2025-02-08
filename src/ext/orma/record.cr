module Orma
  class Record
    stimulus_controller HealthCheckActionController do
      targets :submit
      values interval: Int

      js_method :connect do
        this.submitTarget.click._call
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
        clearInterval(this.timer)
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

    macro health_check_action(name, interval, refreshed_model_template, &blk)
      model_action({{name}}, {{refreshed_model_template}}) do
        def self.action_template(model)
          ::Orma::Record::HealthCheckActionTemplate.new(self.uri_path(model.id), interval)
        end

        def self.interval
          {{interval}}.total_milliseconds.to_i
        end

        {{blk.body}}
      end
    end
  end
end
