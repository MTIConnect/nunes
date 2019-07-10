# frozen_string_literal: true

require 'helper'

class JobInstrumentationTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup :setup_subscriber
  teardown :teardown_subscriber

  def setup_subscriber
    @subscriber = Nunes::Subscribers::ActiveJob.subscribe(adapter)
  end

  def teardown_subscriber
    ActiveSupport::Notifications.unsubscribe @subscriber if @subscriber
  end

  test 'perform_now' do
    post = Post.new(title: 'Testing')
    SpamDetectorJob.perform_now(post)

    expected_tags = {
      job: 'spam_detector_job',
      queue: 'default'
    }

    assert_timer 'active_job.perform.duration.milliseconds', tags: expected_tags
  end

  test 'perform_later' do
    post = Post.create!(title: 'Testing')
    perform_enqueued_jobs do
      SpamDetectorJob.perform_later(post)
    end

    expected_tags = {
      job: 'spam_detector_job',
      queue: 'default'
    }

    assert_counter 'active_job.enqueue.total', tags: expected_tags
    assert_timer   'active_job.perform.duration.milliseconds', tags: expected_tags
  end
end
