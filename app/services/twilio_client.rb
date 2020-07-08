class TwilioClient
  def initialize
    @client = Twilio::REST::Client.new(account_sid, auth_token)
  end

  def send_text(phone_number, msg)
    @client.messages.create(
      to: phone_number,
      from: from_phone_number,
      body: msg
    )
  end

  private

  def account_sid
    Rails.application.credentials[:twilio][:account_sid]
  end

  def auth_token
    Rails.application.credentials[:twilio][:auth_token]
  end

  def from_phone_number
    Rails.application.credentials[:twilio][:phone_number]
  end
end
