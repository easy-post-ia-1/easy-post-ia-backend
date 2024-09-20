# frozen_string_literal: true

# Application mailer example
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
