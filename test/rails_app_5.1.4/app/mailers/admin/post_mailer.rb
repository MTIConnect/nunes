# frozen_string_literal: true

module Admin
  class PostMailer < ApplicationMailer
    default from: 'from@example.com'

    def created
      mail to: 'to@example.org'
    end

    def receive(email)
      # do something
    end
  end
end
