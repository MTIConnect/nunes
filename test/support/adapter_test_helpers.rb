# frozen_string_literal: true

module AdapterTestHelpers
  extend ActiveSupport::Concern

  included do
    setup :setup_memory_adapter, :setup_data
    teardown :clean_data
  end

  attr_reader :adapter

  def setup_memory_adapter
    @adapter = Nunes::Adapters::Memory.new
  end

  def setup_data
    Post.create(title: 'First')
    Post.create(title: 'Second')
  end

  def clean_data
    Post.delete_all
  end

  def assert_timer(metric, opts = {})
    timers = adapter.timers.find_all { |timer| timer.first == metric }
    assert timers.length.positive?
           "Expected the timer #{metric.inspect} to be included in #{adapter.timer_metric_names.inspect}, but it was not."
    assert timers.find { |timer| timer.last == opts },
           "Expected the options #{opts.inspect} to be included in #{timers.map(&:last)}"
  end

  def refute_timer(metric)
    assert !adapter.timer?(metric),
           "Expected the timer #{metric.inspect} to not be included in #{adapter.timer_metric_names.inspect}, but it was."
  end

  def assert_counter(metric, opts = {})
    counters = adapter.counters.find_all { |counter| counter.first == metric }
    assert counters.length.positive?
           "Expected the counter #{metric.inspect} to be included in #{adapter.counter_metric_names.inspect}, but it was not."
    assert counters.find { |counter| counter.last == opts },
           "Expected the options #{opts.inspect} to be included in #{counters.map(&:last)}"
  end

  def refute_counter(metric)
    refute adapter.counter?(metric),
           "Expected the counter #{metric.inspect} to not be included in #{adapter.counter_metric_names.inspect}, but it was."
  end

  def assert_no_counter(metric)
    assert !adapter.counter?(metric),
           "Expected the counter #{metric.inspect} to not be included in adapter.counter_metric_names.inspect}, but it was."
  end
end
