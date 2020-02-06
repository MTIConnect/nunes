# frozen_string_literal: true

require 'helper'

class NamespacedModelInstrumentationTest < ActiveSupport::TestCase
  setup :setup_subscriber
  teardown :teardown_subscriber

  def setup_subscriber
    @subscriber = Nunes::Subscribers::ActiveRecord.subscribe(adapter)
  end

  def teardown_subscriber
    ActiveSupport::Notifications.unsubscribe @subscriber if @subscriber
  end

  test 'transaction' do
    Admin::Post.create(title: 'Testing')

    assert_timer 'active_record.sql.duration.milliseconds', tags: { operation: 'begin' }
    assert_timer 'active_record.sql.duration.milliseconds', tags: { operation: 'commit' }
  end

  test 'create' do
    Admin::Post.create(title: 'Testing')

    assert_timer 'active_record.sql.duration.milliseconds', tags: { operation: 'insert' }
  end

  test 'update' do
    post = Admin::Post.create
    adapter.clear
    post.update_attributes(title: 'Title')

    assert_timer 'active_record.sql.duration.milliseconds', tags: { operation: 'update' }
  end

  test 'find' do
    post = Admin::Post.create
    adapter.clear
    Admin::Post.find(post.id)

    assert_timer 'active_record.sql.duration.milliseconds', tags: { operation: 'select' }
  end

  test 'destroy' do
    post = Admin::Post.create
    adapter.clear
    post.destroy

    assert_timer 'active_record.sql.duration.milliseconds', tags: { operation: 'delete' }
  end
end
