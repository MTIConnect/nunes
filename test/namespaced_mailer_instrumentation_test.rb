# frozen_string_literal: true

require 'helper'

class NamespacedMailerInstrumentationTest < ActionMailer::TestCase
  include ActiveJob::TestHelper

  tests Admin::PostMailer

  setup :setup_subscriber
  teardown :teardown_subscriber

  def setup_subscriber
    @subscriber = Nunes::Subscribers::ActionMailer.subscribe(adapter)
  end

  def teardown_subscriber
    ActiveSupport::Notifications.unsubscribe @subscriber if @subscriber
  end

  test 'deliver_now' do
    Admin::PostMailer.created.deliver_now
    assert_timer 'action_mailer.deliver.duration.milliseconds', tags: { mailer: 'admin_post_mailer' }
  end

  test 'deliver_later' do
    perform_enqueued_jobs do
      Admin::PostMailer.created.deliver_later
    end
    assert_timer 'action_mailer.deliver.duration.milliseconds', tags: { mailer: 'admin_post_mailer' }
  end

  test 'receive' do
    Admin::PostMailer.receive Admin::PostMailer.created
    assert_timer 'action_mailer.receive.duration.milliseconds', tags: { mailer: 'admin_post_mailer' }
  end
end
