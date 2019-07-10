# frozen_string_literal: true

require 'nunes/adapter'

module Nunes
  module Adapters
    # Internal: Memory backend for recording instrumentation calls. This should
    # never need to be used directly by a user of the gem.
    class Memory < ::Nunes::Adapter
      def self.wraps?(client)
        client.is_a?(Hash)
      end

      def initialize(client = nil)
        @client = client || {}
        clear
      end

      def increment(stat, opts = {})
        counters << [prepare(stat), opts]
      end

      def timing(stat, msec, opts = {})
        timers << [prepare(stat), msec, opts]
      end

      # Internal: Returns Array of any recorded timers with durations.
      def timers
        @client.fetch(:timers)
      end

      # Internal: Returns Array of only recorded timers.
      def timer_metric_names
        timers.map(&:first)
      end

      # Internal: Returns true/false if metric has been recorded as a timer.
      def timer?(metric, opts = {})
        timers.detect do |op|
          op.first == metric &&
            op.last == opts
        end
      end

      # Internal: Returns Array of any recorded counters with values.
      def counters
        @client.fetch(:counters)
      end

      # Internal: Returns Array of only recorded counters.
      def counter_metric_names
        counters.map(&:first)
      end

      # Internal: Returns true/false if metric has been recorded as a counter.
      def counter?(metric, opts = {})
        counters.detect do |op|
          op.first == metric &&
            op.last == opts
        end
      end

      # Internal: Empties the known counters and metrics.
      #
      # Returns nothing.
      def clear
        @client ||= {}
        @client.clear
        @client[:timers] = []
        @client[:counters] = []
      end
    end
  end
end
