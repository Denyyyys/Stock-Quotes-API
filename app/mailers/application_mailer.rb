# frozen_string_literal: true

# providing email construction and sending functionality
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
