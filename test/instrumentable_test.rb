# frozen_string_literal: true

require 'helper'

class InstrumentationTest < ActiveSupport::TestCase
  attr_reader :thing_class, :namespaced_thing_class

  setup :setup_subscriber, :setup_class
  teardown :teardown_subscriber, :teardown_class

  def setup_subscriber
    @subscriber = Nunes::Subscribers::Nunes.subscribe(adapter)
  end

  def teardown_subscriber
    ActiveSupport::Notifications.unsubscribe @subscriber if @subscriber
  end

  def setup_class
    @thing_class = Class.new do
      extend Nunes::Instrumentable

      class << self
        extend Nunes::Instrumentable

        def find(*_args)
          :nope
        end
      end

      def self.name
        'Thing'
      end

      def yo(_args = {})
        :dude
      end
    end
    @namespaced_thing_class = Class.new do
      extend Nunes::Instrumentable

      def self.name
        'Some::Thing'
      end

      def yo(_args = {})
        :dude
      end
    end
  end

  def teardown_class
    @thing_class = nil
    @namespaced_thing_class = nil
  end

  test 'adds methods when extended' do
    assert thing_class.respond_to?(:instrument_method_time)
  end

  test 'attempting to instrument time for method twice' do
    thing_class.instrument_method_time :yo

    assert_raises(ArgumentError, 'already instrumented yo for Thing') do
      thing_class.instrument_method_time :yo
    end
  end

  test 'instrument_method_time' do
    thing_class.instrument_method_time :yo

    event = slurp_events { thing_class.new.yo(some: 'thing') }.last

    assert_not_nil event, 'No events were found.'
    assert_equal 'thing.yo', event.payload[:metric]
    assert event.duration > 0, "Expected #{event.duration} to be greater than 0"

    assert_timer 'Thing.yo'
  end

  test 'instrument_method_time for class method without full metric name' do
    # I'd really like to not do this, but I don't have a name for the class
    # which makes it hard to automatically set the name. If anyone has a fix,
    # let me know.
    assert_raises ArgumentError do
      thing_class.singleton_class.instrument_method_time :find
    end
  end

  test 'instrument_method_time for class method' do
    thing_class.singleton_class.instrument_method_time :find, 'Thing.find'

    event = slurp_events { thing_class.find(1) }.last

    assert_not_nil event, 'No events were found.'
    assert_equal 'Thing.find', event.payload[:metric]
    assert event.duration > 0, "Expected #{event.duration} to be greater than 0"

    assert_timer 'Thing.find'
  end

  test 'instrument_method_time with custom name in hash' do
    thing_class.instrument_method_time :yo, name: 'Thingy.yohoho'

    event = slurp_events { thing_class.new.yo(some: 'thing') }.last

    assert_not_nil event, 'No events were found.'
    assert_equal 'Thingy.yohoho', event.payload[:metric]

    assert_timer 'Thingy.yohoho'
  end

  test 'instrument_method_time with custom name as string' do
    thing_class.instrument_method_time :yo, 'Thingy.yohoho'

    event = slurp_events { thing_class.new.yo(some: 'thing') }.last

    assert_not_nil event, 'No events were found.'
    assert_equal 'Thingy.yohoho', event.payload[:metric]

    assert_timer 'Thingy.yohoho'
  end

  test 'instrument_method_time with custom payload' do
    thing_class.instrument_method_time :yo, payload: { pay: 'loadin' }

    event = slurp_events { thing_class.new.yo(some: 'thing') }.last

    assert_not_nil event, 'No events were found.'
    assert_equal 'loadin', event.payload[:pay]

    assert_timer 'thing.yo'
  end

  test 'instrument_method_time for namespaced class' do
    namespaced_thing_class.instrument_method_time :yo

    event = slurp_events { namespaced_thing_class.new.yo(some: 'thing') }.last

    assert_not_nil event, 'No events were found.'
    assert_equal 'some-Thing.yo', event.payload[:metric]
    assert event.duration > 0, "Expected #{event.duration} to be greater than 0"

    assert_timer 'Some-Thing.yo'
  end

  def slurp_events(&block)
    events = []
    callback = ->(*args) { events << ActiveSupport::Notifications::Event.new(*args) }
    ActiveSupport::Notifications.subscribed(callback, Nunes::Instrumentable::MethodTimeEventName, &block)
    events
  end
end
