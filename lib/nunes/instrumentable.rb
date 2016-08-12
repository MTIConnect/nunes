require "active_support/notifications"

module Nunes
  module Instrumentable
    # Private
    MethodTimeEventName = "instrument_method_time.nunes".freeze

    # Public: Instrument a method's timing by name.
    #
    # method_name - The String or Symbol name of the method.
    # options_or_string - The Hash of options or the String metic name.
    #           :payload - Any items you would like to include with the
    #                      instrumentation payload.
    #           :name - The String name of the event and namespace.
    def instrument_method_time(method_name, options_or_string = nil)
      options = options_or_string || {}
      options = {name: options} if options.is_a?(String)

      action = :time
      payload = options.fetch(:payload) { {} }
      instrumenter = options.fetch(:instrumenter) { ActiveSupport::Notifications }

      payload[:metric] = options.fetch(:name) {
        if name.nil?
          raise ArgumentError, "For class methods you must provide the full name of the metric."
        else
          "#{::Nunes.class_to_metric(name)}.#{method_name}"
        end
      }

      nunes_wrap_method(method_name, action) do |old_method_name, new_method_name|
        define_method(new_method_name) do |*args, &block|
          instrumenter.instrument(MethodTimeEventName, payload) {
            send(old_method_name, *args, &block)
          }
        end
      end
    end

    # Private: And so horrendously ugly...
    def nunes_wrap_method(method_name, action, &block)
      method_without_instrumentation = :"#{method_name}_without_#{action}"
      method_with_instrumentation = :"#{method_name}_with_#{action}"

      if method_defined?(method_without_instrumentation)
        raise ArgumentError, "already instrumented #{method_name} for #{self.name}"
      end

      if !method_defined?(method_name) && !private_method_defined?(method_name)
        raise ArgumentError, "could not find method #{method_name} for #{self.name}"
      end

      alias_method method_without_instrumentation, method_name
      yield method_without_instrumentation, method_with_instrumentation
      alias_method method_name, method_with_instrumentation
    end
  end
end
