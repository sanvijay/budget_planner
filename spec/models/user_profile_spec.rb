require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  let(:user) { User.new(email: "sample@example.com") }
  let(:user_profile) { user.build_user_profile(valid_attr) }

  let(:valid_attr) do
    {
      first_name: "Bike",
      last_name: "Racer",
      dob: Date.today - 1.days,
      gender: "Male"
    }
  end

  describe "validations" do
    it 'does not create record without parent' do
      expect { described_class.create(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'is a valid user_profile' do
      expect(user_profile).to be_valid
    end

    it 'does not allow empty / blank first_name' do
      user_profile.first_name = '     '
      expect(user_profile).not_to be_valid
    end

    it 'does not allow long character for first_name' do
      user_profile.first_name = 'a' * 51
      expect(user_profile).not_to be_valid
    end

    it 'does not allow empty value for last_name' do
      user_profile.last_name = '     '
      expect(user_profile).not_to be_valid
    end

    it 'does not allow non-numeric character for last_name' do
      user_profile.last_name = 'a' * 51
      expect(user_profile).not_to be_valid
    end

    it 'does not allow empty value for dob' do
      user_profile.dob = '     '
      expect(user_profile).not_to be_valid
    end

    it 'does not allow future dob' do
      user_profile.dob = Date.today + 1.days
      expect(user_profile).not_to be_valid
    end

    it 'does not allow empty value for gender' do
      user_profile.gender = '     '
      expect(user_profile).not_to be_valid
    end

    it "allows gender from the provided list" do
      UserProfile::GENDERS.values.each do |gender|
        user_profile.gender = gender
        expect(user_profile).to be_valid
      end
    end

    it "does not allow gender other than provider list" do
      ["Test", 123, Date.today].each do |invalid_gender|
        user_profile.gender = invalid_gender
        expect(user_profile).not_to be_valid
      end
    end
  end
end
