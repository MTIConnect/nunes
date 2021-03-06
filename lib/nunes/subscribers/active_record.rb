# frozen_string_literal: true

require 'nunes/subscriber'

module Nunes
  module Subscribers
    class ActiveRecord < ::Nunes::Subscriber
      # Private
      Pattern = /\.active_record\Z/.freeze

      # Private: The namespace for events to subscribe to.
      def self.pattern
        Pattern
      end

      # Private: Used to detect the operation from the sql.
      Space = ' '

      def sql(start, ending, _transaction_id, payload)
        runtime = (ending - start) * 1_000
        sql = payload[:sql].to_s.strip
        operation = sql.split(Space, 2).first.to_s.downcase

        timing 'active_record.sql.duration.milliseconds', runtime, tags: { operation: operation }
      end
    end
  end
end
