# frozen_string_literal: true

class PostMailer < ActionMailer::Base
  default from: 'from@example.com'

  def created
    mail to: 'to@example.org'
  end

  def receive(email)
    # do something
  end
end
