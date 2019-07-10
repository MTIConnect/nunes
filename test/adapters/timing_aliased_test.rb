# frozen_string_literal: true

require 'helper'
require 'minitest/mock'

class TimingAliasedAdapterTest < ActiveSupport::TestCase
  test 'passes increment along' do
    mock = MiniTest::Mock.new
    mock.expect :increment, nil, ['single', tags: { food: 'bar' }]

    client = Nunes::Adapters::TimingAliased.new(mock)
    client.increment('single', tags: { food: 'bar' })

    mock.verify
  end

  test 'sends timing to gauge' do
    mock = MiniTest::Mock.new
    mock.expect :gauge, nil, ['foo', 23, tags: { foo: 'bar' }]

    client = Nunes::Adapters::TimingAliased.new(mock)
    client.timing('foo', 23, tags: { foo: 'bar' })

    mock.verify
  end
end
