require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { described_class.new(email: "example_user@example.com", password: "Qweasd12!") }

  describe "validations" do
    it 'is a valid user' do
      expect(user).to be_valid
    end

    it 'is invalid with empty email string' do
      user.email = '     '
      expect(user).not_to be_valid
    end

    it 'is invalid with empty referring_token string' do
      user.referring_token = '     '
      expect(user).not_to be_valid
    end

    it 'does not allow long email > 256 characters' do
      user.email = 'a' * 244 + '@example.com'
      expect(user).not_to be_valid
    end

    it "accepts valid format of email" do
      valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                           first.last@foo.jp alice+bob@baz.cn]

      valid_addresses.each do |valid_address|
        user.email = valid_address
        expect(user).to be_valid
      end
    end

    it "does not allow invalid format of email" do
      invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                             foo@bar_baz.com foo@bar+baz.com foo@bar..com]

      invalid_addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).not_to be_valid
      end
    end

    it "accepts nil phone_number" do
      user.phone_number = nil
      expect(user).to be_valid
    end

    it "accepts valid format of phone" do
      valid_numbers = %w[+919999999999 9999999999]

      valid_numbers.each do |valid_number|
        user.phone_number = valid_number
        expect(user).to be_valid
      end
    end

    it "does not allow invalid format of phone" do
      invalid_numbers = %w[+91999999999 999999999 abc (+91)9999999999]

      invalid_numbers.each do |invalid_number|
        user.phone_number = invalid_number
        expect(user).not_to be_valid
      end
    end

    it "does not allow duplicate user with same email" do
      duplicate_user = user.dup
      duplicate_user.email = user.email.upcase
      user.save
      expect(duplicate_user).not_to be_valid
    end

    it "saves the email addresses as lower-case" do
      mixed_case_email = "Foo@ExAMPle.CoM"
      user.email = mixed_case_email
      user.save
      expect(user.reload.email).to eq mixed_case_email.downcase
    end

    it 'is not valid if refer code is duplicate' do
      duplicate_user = user.dup
      duplicate_user.referring_token = user.referring_token
      user.save
      expect(duplicate_user).not_to be_valid
    end

    it 'does not regenerate referring_token on each save' do
      user.save
      new_token = user.referring_token
      user.save

      expect(new_token).to eq(user.referring_token)
    end
  end

  describe "callbacks" do
    it "creates token before saving user" do
      user.save!
      expect(user.referring_token).not_to be_nil
    end
  end

  describe "#verify_phone" do
    it "does not verify phone_number if phone_number is nil" do
      user.phone_number = nil
      user.phone_pin = "123"
      user.save!

      expect(user.verify_phone("123")).to be_falsey
      expect(user.phone_verified).to be_falsey
    end

    it "does not verify phone_number if pin does not match" do
      user.phone_number = "9999999999"
      user.phone_pin = "123"
      user.save!

      expect(user.verify_phone("1234")).to be_falsey
      expect(user.phone_verified).to be_falsey
    end

    it "verifies the phone_number if pin the pin match" do
      user.phone_number = "9999999999"
      user.phone_pin = "123"
      user.save!

      user.verify_phone("123")

      expect(user.phone_verified).to be_truthy
      expect(user.phone_pin).to be_nil
      expect(user.phone_verified_on).not_to be_nil
    end
  end

  describe "generate_and_send_phone_pin!" do
    it "does not generates the pin when no number is given" do
      user.phone_number = nil
      user.save!

      user.generate_and_send_phone_pin!
      expect(user.phone_pin).to be_nil
    end

    it "generates and sends sms when number is given" do
      user.phone_number = "9999999999"
      user.save!

      expect(user).to receive(:send_phone_pin).and_return(nil)
      user.generate_and_send_phone_pin!
      expect(user.phone_pin).to match(/\A\d{6}\z/)
    end
  end

  it "returns _id for primary key which is used by devise" do
    expect(described_class.primary_key).to eq '_id'
  end

  it "is not a enabled user" do
    user.save!
    expect(user).not_to be_enabled
  end

  it "is a enabled user" do
    user.save!
    user.create_user_profile(first_name: "Bike", last_name: "Racer", dob: Time.zone.today - 1.day, gender: "Male")

    expect(user).to be_enabled
  end

  it "creates a user_access and user_profile" do
    user.save!

    expect(user.user_profile).to be_new_record
    expect(user.user_access).to be_new_record
  end
end
