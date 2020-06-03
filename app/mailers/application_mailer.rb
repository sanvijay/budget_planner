class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials[:email][:id]
  layout 'mailer'
end
