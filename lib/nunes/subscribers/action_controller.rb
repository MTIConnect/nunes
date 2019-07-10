# frozen_string_literal: true

require 'nunes/subscriber'

module Nunes
  module Subscribers
    class ActionController < ::Nunes::Subscriber
      # Private
      Pattern = /\.action_controller\Z/.freeze

      # Private: The namespace for events to subscribe to.
      def self.pattern
        Pattern
      end

      class << self
        attr_accessor :instrument_view_runtime
        attr_accessor :instrument_db_runtime
      end

      # Public: Should we instrument the view runtime overall and per controller/action.
      self.instrument_view_runtime = true

      # Public: Should we instrument the db runtime overall and per controller/action.
      self.instrument_db_runtime = true

      def process_action(start, ending, _transaction_id, payload)
        runtime = (ending - start) * 1_000

        tags = {
          status: payload[:status],
          controller: ::Nunes.class_to_metric(payload[:controller]),
          action: payload[:action]
        }.compact

        timing 'action_controller.request.duration.milliseconds', runtime, tags: tags
        increment 'action_controller.requests.total', tags: tags if tags[:status]

        if self.class.instrument_view_runtime && payload[:view_runtime]
          view_runtime = payload[:view_runtime].round
          timing 'action_controller.render.duration.milliseconds', view_runtime, tags: tags
        end

        if self.class.instrument_db_runtime && payload[:db_runtime]
          db_runtime = payload[:db_runtime].round
          timing 'action_controller.db.duration.milliseconds', db_runtime, tags: tags
        end
      end

      ##########################################################################
      # All of the events below don't really matter. Most of them also go      #
      # through process_action. The only value that could be pulled from them  #
      # would be topk related which graphite doesn't do.                       #
      ##########################################################################

      def start_processing(*)
        # noop
      end

      def halted_callback(*)
        # noop
      end

      def redirect_to(*)
        # noop
      end

      def send_file(*)
        # noop
      end

      def send_data(*)
        # noop
      end
    end
  end
end
