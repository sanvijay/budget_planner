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
