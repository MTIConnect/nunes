# frozen_string_literal: true

require 'helper'

class NamespacedControllerInstrumentationTest < ActionController::TestCase
  tests Admin::PostsController

  setup :setup_subscriber
  teardown :teardown_subscriber

  def setup_subscriber
    @subscriber = Nunes::Subscribers::ActionController.subscribe(adapter)
  end

  def teardown_subscriber
    ActiveSupport::Notifications.unsubscribe @subscriber if @subscriber
  end

  test 'process_action' do
    get :index

    assert_response :success

    expected_tags = {
      foo: 'bar',
      status: 200,
      controller: 'admin_posts_controller',
      action: 'index'
    }

    assert_counter 'action_controller.requests.total', tags: expected_tags

    assert_timer 'action_controller.request.duration.milliseconds', tags: expected_tags
    assert_timer 'action_controller.db.duration.milliseconds', tags: expected_tags
    assert_timer 'action_controller.render.duration.milliseconds', tags: expected_tags
  end

  test 'process_action bad_request' do
    get :new

    assert_response :forbidden

    expected_tags = {
      status: 403,
      controller: 'admin_posts_controller',
      action: 'new'
    }

    assert_counter 'action_controller.requests.total', tags: expected_tags

    assert_timer 'action_controller.request.duration.milliseconds', tags: expected_tags
    assert_timer 'action_controller.db.duration.milliseconds', tags: expected_tags
  end
end
