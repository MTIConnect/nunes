# frozen_string_literal: true

require 'active_support/core_ext/class/subclasses'

module Nunes
  class Adapter
    # Private: Wraps a given object with the correct adapter/decorator.
    #
    # client - The thing to be wrapped.
    #
    # Returns Nunes::Adapter instance.
    def self.wrap(client)
      raise ArgumentError, 'client cannot be nil' if client.nil?
      return client if client.is_a?(self)

      adapter = adapters.detect { |adapter| adapter.wraps?(client) }

      if adapter.nil?
        raise ArgumentError,
              "I have no clue how to wrap what you've given me (#{client.inspect})"
      end

      adapter.new(client)
    end

    # Private
    def self.wraps?(client)
      client.respond_to?(:increment) && client.respond_to?(:timing)
    end

    # Private
    def self.adapters
      [Nunes::Adapter, *subclasses]
    end

    # Private
    attr_reader :client

    # Internal: Sets the client for the adapter.
    #
    # client - The thing being adapted to a simple interface.
    def initialize(client)
      @client = client
    end

    # Internal: Increment a metric by a value. Override in subclass if client
    # interface does not match.
    def increment(stat, opts = {})
      @client.increment prepare(stat), opts
    end

    # Internal: Record a metric's duration. Override in subclass if client
    # interface does not match.
    def timing(stat, msec, opts = {})
      @client.timing prepare(stat), msec, opts
    end

    # Private: What Ruby uses to separate namespaces.
    ReplaceRegex = /[^a-z0-9\-_]+/i.freeze

    # Private: The default metric namespace separator.
    Separator = '.'

    # Private
    Nothing = ''

    # Private: Prepare a metric name before it is sent to the adapter's client.
    def prepare(metric, replacement = Separator)
      escaped = Regexp.escape(replacement)
      replace_begin_end_regex = /\A#{escaped}|#{escaped}\Z/

      metric = metric.to_s.gsub(ReplaceRegex, replacement)
      metric.squeeze!(replacement)
      metric.gsub!(replace_begin_end_regex, Nothing)
      metric
    end
  end
end
