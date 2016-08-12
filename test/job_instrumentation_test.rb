require "helper"

class JobInstrumentationTest < ActiveSupport::TestCase
  setup :setup_subscriber
  teardown :teardown_subscriber

  def setup_subscriber
    @subscriber = Nunes::Subscribers::ActiveJob.subscribe(adapter)
  end

  def teardown_subscriber
    ActiveSupport::Notifications.unsubscribe @subscriber if @subscriber
  end

  test "perform_now" do
    post = Post.new(title: 'Testing')
    SpamDetectorJob.perform_now(post)

    assert_timer   "active_job.SpamDetectorJob.perform"
  end

  test "perform_later" do
    post = Post.create!(title: 'Testing')
    SpamDetectorJob.perform_later(post)

    assert_timer   "active_job.SpamDetectorJob.perform"
    assert_counter "active_job.SpamDetectorJob.enqueue"
  end
end
