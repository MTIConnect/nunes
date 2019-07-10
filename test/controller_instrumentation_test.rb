# frozen_string_literal: true

require 'helper'

class ControllerInstrumentationTest < ActionController::TestCase
  tests PostsController

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
      status: 200,
      controller: 'posts_controller',
      action: 'index',
      foo: 'bar'
    }

    assert_counter 'action_controller.requests.total', tags: expected_tags

    assert_timer 'action_controller.request.duration.milliseconds', tags: expected_tags
    assert_timer 'action_controller.db.duration.milliseconds', tags: expected_tags
    assert_timer 'action_controller.render.duration.milliseconds', tags: expected_tags
  end

  test 'send_data' do
    get :some_data

    assert_response :success

    expected_tags = {
      status: 200,
      controller: 'posts_controller',
      action: 'some_data'
    }

    assert_counter 'action_controller.requests.total', tags: expected_tags

    assert_timer 'action_controller.request.duration.milliseconds', tags: expected_tags
    assert_timer 'action_controller.render.duration.milliseconds', tags: expected_tags
  end

  test 'send_file' do
    get :some_file

    assert_response :success

    expected_tags = {
      status: 200,
      controller: 'posts_controller',
      action: 'some_file'
    }

    assert_counter 'action_controller.requests.total', tags: expected_tags

    assert_timer 'action_controller.request.duration.milliseconds', tags: expected_tags

    refute_timer 'action_controller.render.duration.millisconds'
  end

  test 'redirect_to' do
    get :some_redirect

    assert_response :redirect

    expected_tags = {
      status: 302,
      controller: 'posts_controller',
      action: 'some_redirect'
    }

    assert_counter 'action_controller.requests.total', tags: expected_tags

    assert_timer 'action_controller.request.duration.milliseconds', tags: expected_tags

    refute_timer 'action_controller.render.duration.millisconds'
  end

  test 'action with exception' do
    begin
      get :some_boom
    rescue StandardError
      StandardError
    end # catch the boom

    assert_response :success

    expected_tags = {
      status: 500,
      controller: 'posts_controller',
      action: 'some_boom'
    }

    assert_counter 'action_controller.requests.total', tags: expected_tags

    assert_timer 'action_controller.request.duration.milliseconds', tags: expected_tags

    refute_timer 'action_controller.render.duration.millisconds'
  end

  test 'with instrument db runtime disabled' do
    begin
      original_db_enabled = Nunes::Subscribers::ActionController.instrument_db_runtime
      Nunes::Subscribers::ActionController.instrument_db_runtime = false

      get :index

      refute_timer 'action_controller.db.duration.millisconds'
    ensure
      Nunes::Subscribers::ActionController.instrument_db_runtime = original_db_enabled
    end
  end

  test 'with instrument render runtime disabled' do
    begin
      original_render_enabled = Nunes::Subscribers::ActionController.instrument_render_runtime
      Nunes::Subscribers::ActionController.instrument_render_runtime = false

      get :index

      refute_timer 'action_controller.render.duration.millisconds'
    ensure
      Nunes::Subscribers::ActionController.instrument_render_runtime = original_render_enabled
    end
  end
end
