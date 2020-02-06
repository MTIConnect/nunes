# frozen_string_literal: true

require 'nunes/subscriber'

module Nunes
  module Subscribers
    class Nunes < ::Nunes::Subscriber
      # Private
      Pattern = /\.nunes\Z/.freeze

      # Private: The namespace for events to subscribe to.
      def self.pattern
        Pattern
      end

      def instrument_method_time(start, ending, _transaction_id, payload)
        runtime = (ending - start) * 1_000
        metric = payload[:metric]

        timing metric, runtime if metric
      end
    end
  end
end
