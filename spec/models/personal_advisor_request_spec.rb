require 'rails_helper'

RSpec.describe PersonalAdvisorRequest, type: :model do
  let(:personal_advisor_request) do
    described_class.new(
      first_name: "Example",
      last_name: "User",
      email: "example_user@example.com",
      phone_number: "123123123"
    )
  end

  describe "validations" do
    it 'is a valid personal_advisor_request' do
      expect(personal_advisor_request).to be_valid
    end

    it 'does not allow empty / blank first_name' do
      personal_advisor_request.first_name = '     '
      expect(personal_advisor_request).not_to be_valid
    end

    it 'does not allow long character for first_name' do
      personal_advisor_request.first_name = 'a' * 51
      expect(personal_advisor_request).not_to be_valid
    end

    it 'does not allow empty / blank last_name' do
      personal_advisor_request.last_name = '     '
      expect(personal_advisor_request).not_to be_valid
    end

    it 'does not allow long character for last_name' do
      personal_advisor_request.last_name = 'a' * 51
      expect(personal_advisor_request).not_to be_valid
    end

    it 'does not allow empty / blank email' do
      personal_advisor_request.email = '     '
      expect(personal_advisor_request).not_to be_valid
    end

    it 'does not allow long character for email' do
      personal_advisor_request.email = 'a' * 244 + '@example.com'
      expect(personal_advisor_request).not_to be_valid
    end

    it 'does not allow empty / blank phone_number' do
      personal_advisor_request.phone_number = '     '
      expect(personal_advisor_request).not_to be_valid
    end

    it "accepts valid format of email" do
      valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                           first.last@foo.jp alice+bob@baz.cn]

      valid_addresses.each do |valid_address|
        personal_advisor_request.email = valid_address
        expect(personal_advisor_request).to be_valid
      end
    end

    it "does not allow invalid format of email" do
      invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                             foo@bar_baz.com foo@bar+baz.com foo@bar..com]

      invalid_addresses.each do |invalid_address|
        personal_advisor_request.email = invalid_address
        expect(personal_advisor_request).not_to be_valid
      end
    end

    it "does not allow duplicate user with same email" do
      duplicate_user = personal_advisor_request.dup
      duplicate_user.email = personal_advisor_request.email.upcase
      personal_advisor_request.save
      expect(duplicate_user).not_to be_valid
    end

    it "saves the email addresses as lower-case" do
      mixed_case_email = "Foo@ExAMPle.CoM"
      personal_advisor_request.email = mixed_case_email
      personal_advisor_request.save
      expect(personal_advisor_request.reload.email).to eq mixed_case_email.downcase
    end
  end
end
