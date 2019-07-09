require "nunes/subscriber"

module Nunes
  module Subscribers
    class ActiveSupport < ::Nunes::Subscriber
      # Private
      Pattern = /\.active_support\Z/

      # Private: The namespace for events to subscribe to.
      def self.pattern
        Pattern
      end

      def cache_read(start, ending, transaction_id, payload)
        super_operation = payload[:super_operation]
        runtime = (ending - start) * 1_000

        case super_operation
        when Symbol
          timing "active_support.cache.#{super_operation}.duration.milliseconds", runtime
        else
          timing 'active_support.cache.read.duration.milliseconds', runtime
        end

        hit = payload[:hit]
        unless hit.nil?
          hit_type = hit ? :hit : :miss
          increment "active_support.cache.#{hit_type}.total"
        end
      end

      def cache_generate(start, ending, transaction_id, payload)
        runtime = (ending - start) * 1_000
        timing 'active_support.cache.fetch_generate.duration.milliseconds', runtime
      end

      def cache_fetch_hit(start, ending, transaction_id, payload)
        runtime = (ending - start) * 1_000
        timing 'active_support.cache.fetch_hit.duration.milliseconds', runtime
      end

      def cache_write(start, ending, transaction_id, payload)
        runtime = (ending - start) * 1_000
        timing 'active_support.cache.write.duration.milliseconds', runtime
      end

      def cache_delete(start, ending, transaction_id, payload)
        runtime = (ending - start) * 1_000
        timing 'active_support.cache.delete.duration.milliseconds', runtime
      end

      def cache_exist?(start, ending, transaction_id, payload)
        runtime = (ending - start) * 1_000
        timing 'active_support.cache.exist.duration.milliseconds', runtime
      end
    end
  end
end
