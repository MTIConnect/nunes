require "nunes/subscriber"

module Nunes
  module Subscribers
    class ActionView < ::Nunes::Subscriber
      # Private
      Pattern = /\.action_view\Z/

      # Private: The namespace for events to subscribe to.
      def self.pattern
        Pattern
      end

      def render_template(start, ending, transaction_id, payload)
        instrument_identifier :template, payload[:identifier], start, ending
      end

      def render_partial(start, ending, transaction_id, payload)
        instrument_identifier :partial, payload[:identifier], start, ending
      end

      private

      # Private: What to replace file separators with.
      FileSeparatorReplacement = "_".freeze

      # Private: An empty string.
      Nothing = "".freeze

      # Private: Sends timing information about identifier event.
      def instrument_identifier(kind, identifier, start, ending)
        if identifier
          runtime = (ending - start) * 1_000
          raw_view_path = identifier.to_s.gsub(::Rails.root.to_s, Nothing)
          view_path = adapter.prepare(raw_view_path, FileSeparatorReplacement)
          timing 'action_view.render.duration.milliseconds', runtime, tags: { kind: kind , view_path: view_path }
        end
      end
    end
  end
end
