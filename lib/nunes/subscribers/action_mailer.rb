# frozen_string_literal: true

require 'nunes/subscriber'

module Nunes
  module Subscribers
    class ActionMailer < ::Nunes::Subscriber
      # Private
      Pattern = /\.action_mailer\Z/.freeze

      # Private: The namespace for events to subscribe to.
      def self.pattern
        Pattern
      end

      def deliver(start, ending, _transaction_id, payload)
        runtime = (ending - start) * 1_000
        mailer = ::Nunes.class_to_metric(payload[:mailer])

        if mailer
          timing 'action_mailer.deliver', runtime, tags: { mailer: mailer }
        end
      end

      def receive(start, ending, _transaction_id, payload)
        runtime = (ending - start) * 1_000
        mailer = ::Nunes.class_to_metric(payload[:mailer])

        if mailer
          timing 'action_mailer.receive', runtime, tags: { mailer: mailer }
        end
      end
    end
  end
end
