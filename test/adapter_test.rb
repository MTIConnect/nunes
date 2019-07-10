# frozen_string_literal: true

require 'helper'
require 'minitest/mock'

class AdapterTest < ActiveSupport::TestCase
  def separator
    Nunes::Adapter::Separator
  end

  test 'wrap for statsd' do
    client_with_gauge_and_timing = Class.new do
      def increment(*args); end

      def gauge(*args); end

      def timing(*args); end
    end.new

    adapter = Nunes::Adapter.wrap(client_with_gauge_and_timing)
    assert_instance_of Nunes::Adapter, adapter
  end

  test 'wrap for instrumental' do
    client_with_gauge_but_not_timing = Class.new do
      def increment(*args); end

      def gauge(*args); end
    end.new

    adapter = Nunes::Adapter.wrap(client_with_gauge_but_not_timing)
    assert_instance_of Nunes::Adapters::TimingAliased, adapter
  end

  test 'wrap for adapter' do
    memory = Nunes::Adapters::Memory.new
    adapter = Nunes::Adapter.wrap(memory)
    assert_equal memory, adapter
  end

  test 'wrap with hash' do
    hash = {}
    adapter = Nunes::Adapter.wrap(hash)
    assert_instance_of Nunes::Adapters::Memory, adapter
  end

  test 'wrap with nil' do
    assert_raises(ArgumentError) { Nunes::Adapter.wrap(nil) }
  end

  test 'wrap with straight up gibberish yo' do
    assert_raises(ArgumentError) { Nunes::Adapter.wrap(Object.new) }
  end

  test 'passes increment along' do
    mock = MiniTest::Mock.new
    mock.expect :increment, nil, ['single', tags: { foo: 'bar' }]

    client = Nunes::Adapter.new(mock)
    client.increment('single', tags: { foo: 'bar' })

    mock.verify
  end

  test 'passes timing along' do
    mock = MiniTest::Mock.new
    mock.expect :timing, nil, ['foo', 23, { tags: { foo: 'bar' } }]

    client = Nunes::Adapter.new(mock)
    client.timing('foo', 23, tags: { foo: 'bar' })

    mock.verify
  end

  test 'prepare leaves good metrics alone' do
    adapter = Nunes::Adapter.new(nil)

    [
      'foo',
      'foo1234',
      'foo-bar',
      'foo_bar',
      'Foo',
      'FooBar',
      'FOOBAR',
      "foo#{separator}bar",
      "foo#{separator}bar_baz",
      "foo#{separator}bar_baz-wick",
      "Foo#{separator}1234",
      "Foo#{separator}Bar1234"
    ].each do |expected|
      assert_equal expected, adapter.prepare(expected)
    end
  end

  test 'prepare with bad metric names' do
    adapter = Nunes::Adapter.new(nil)

    {
      "#{separator}foo" => 'foo',
      "foo#{separator}" => 'foo',
      'foo@bar' => "foo#{separator}bar",
      'foo@$%^*^&bar' => "foo#{separator}bar",
      "foo#{separator}#{separator}bar" => "foo#{separator}bar",
      'app/views/posts' => "app#{separator}views#{separator}posts",
      "Admin::PostsController#{separator}index" => "Admin#{separator}PostsController#{separator}index"
    }.each do |metric, expected|
      assert_equal expected, adapter.prepare(metric)
    end
  end

  test 'prepare does not modify original metric object' do
    adapter = Nunes::Adapter.new(nil)
    original = 'app.views.posts'
    _ = adapter.prepare('original')

    assert_equal 'app.views.posts', original
  end
end
