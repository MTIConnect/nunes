require "helper"

class NamespacedJobInstrumentationTest < ActiveSupport::TestCase
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
    Spam::DetectorJob.perform_now(post)

    assert_timer   "active_job.Spam.DetectorJob.perform"
  end

  test "perform_later" do
    post = Post.create!(title: 'Testing')
    Spam::DetectorJob.perform_later(post)

    assert_timer   "active_job.Spam.DetectorJob.perform"
    assert_counter "active_job.Spam.DetectorJob.enqueue"
  end
end
