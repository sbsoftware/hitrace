module Orma
  class Record
    stimulus_controller HealthCheckActionController do
      targets :submit
      values interval: Int

      js_method :connect do
        setTimeout(-> {
          this.submitTarget.click._call
        }, this.intervalValue)
      end
    end

    macro health_check_action(name, interval, refreshed_model_template, &blk)
      model_action({{name}}, {{refreshed_model_template}}) do
        def interval
          {{interval}}.total_milliseconds.to_i
        end

        view do
          template do
            div HealthCheckActionController, HealthCheckActionController.interval_value(action.interval.to_s) do
              action_form(hidden: true).to_html do
                input HealthCheckActionController.submit_target, type: :submit, value: "Submit"
              end
            end
          end
        end

        {{blk.body}}
      end
    end
  end
end
