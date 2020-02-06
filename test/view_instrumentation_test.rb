# frozen_string_literal: true

require 'helper'

class ViewInstrumentationTest < ActionController::TestCase
  tests PostsController

  setup :setup_subscriber
  teardown :teardown_subscriber

  def setup_subscriber
    @subscriber = Nunes::Subscribers::ActionView.subscribe(adapter)
  end

  def teardown_subscriber
    ActiveSupport::Notifications.unsubscribe @subscriber if @subscriber
  end

  test 'render_template' do
    get :index

    assert_response :success
    assert_timer 'action_view.render.duration.milliseconds', tags: { kind: 'template', path: 'app_views_posts_index_html_erb' }
  end

  test 'render_partial' do
    get :index

    assert_response :success
    assert_timer 'action_view.render.duration.milliseconds', tags: { kind: 'partial', path: 'app_views_posts_post_html_erb' }
  end
end
