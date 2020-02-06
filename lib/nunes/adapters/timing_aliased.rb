# frozen_string_literal: true

require 'nunes/adapter'

module Nunes
  module Adapters
    # Internal: Adapter that aliases timing to gauge. One of the supported
    # places to send instrumentation data is instrumentalapp.com. Their agent
    # uses gauge under the hood for timing information. This adapter is used to
    # adapter their gauge interface to the timing one used internally in the
    # gem. This should never need to be used directly by a user of the gem.
    class TimingAliased < ::Nunes::Adapter
      def self.wraps?(client)
        client.respond_to?(:increment) &&
          client.respond_to?(:gauge) &&
          !client.respond_to?(:timing)
      end

      # Internal: Adapter timing to gauge.
      def timing(stat, msec, opts = {})
        @client.gauge prepare(stat), msec, opts
      end
    end
  end
end
