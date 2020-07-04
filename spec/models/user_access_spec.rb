require 'rails_helper'

RSpec.describe UserAccess, type: :model do
  let(:user)         { User.new(email: "sample@example.com", password: "Qweasd12!") }
  let(:user_access)  { user.build_user_access(valid_attr) }

  let(:valid_attr) { {} }

  describe "validations" do
    it 'does not create record without parent' do
      expect { described_class.create(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'is a valid user_access' do
      expect(user_access).to be_valid
    end

    it "sets the default value of model to 'free'" do
      expect(user_access.model).to eq :free
    end

    it 'is not valid for non allowed model' do
      user_access.model = 'test'
      expect(user_access).not_to be_valid
    end

    it 'is not valid for non allowed referred_by user' do
      user_access.referred_by = 'test'
      expect(user_access).not_to be_valid
    end

    it 'is valid if referred_by is valid user' do
      new_user = User.create(email: "sample2@example.com", password: "Qweasd12!")
      user_access.referred_by = new_user.to_param
      expect(user_access).to be_valid
    end

    it 'is valid if referred_users is valid users' do
      new_user = User.create(email: "sample2@example.com", password: "Qweasd12!")
      user_access.referred_users << new_user.to_param
      expect(user_access).to be_valid
    end

    it 'is not valid if referred_users doesnt contains invalid users' do
      user_access.referred_users << "test"
      expect(user_access).not_to be_valid
    end

    it 'is not valid if referred_users doesnt contains nil' do
      user_access.referred_users << nil
      expect(user_access).not_to be_valid
    end
  end

  describe "callbacks" do
    it "creates token before saving user_access" do
      user_access.save!
      expect(user_access.referring_token).not_to be_nil
    end

    it "creates token before saving user" do
      user.save!
      expect(user.user_access.referring_token).not_to be_nil
    end
  end

  describe "#claim_plus_access" do
    it 'returns false on no referred_users' do
      expect(user_access.claim_plus_access?).to be_falsey # rubocop:disable RSpec/PredicateMatcher
    end

    it 'checks for number of referrals for claim_plus_access?' do
      new_user1 = User.create(email: "sample1@example.com", password: "Qweasd12!", phone_verified: true)
      new_user2 = User.create(email: "sample2@example.com", password: "Qweasd12!", phone_verified: true)
      new_user3 = User.create(email: "sample3@example.com", password: "Qweasd12!", phone_verified: true)

      user_access.referred_users << new_user1.to_param
      user_access.referred_users << new_user2.to_param
      user_access.referred_users << new_user3.to_param

      expect(user_access.claim_plus_access?).to be_truthy # rubocop:disable RSpec/PredicateMatcher
    end

    it 'returns false on one referred_users didnt completed his profile' do
      new_user1 = User.create(email: "sample1@example.com", password: "Qweasd12!", phone_verified: true)
      new_user2 = User.create(email: "sample2@example.com", password: "Qweasd12!", phone_verified: true)
      new_user3 = User.create(email: "sample3@example.com", password: "Qweasd12!")

      user_access.referred_users << new_user1.to_param
      user_access.referred_users << new_user2.to_param
      user_access.referred_users << new_user3.to_param

      expect(user_access.claim_plus_access?).to be_falsey # rubocop:disable RSpec/PredicateMatcher
    end

    it 'sets the account model to be plus on successful referral' do
      user_access.save!
      new_user1 = User.create(email: "sample1@example.com", password: "Qweasd12!", phone_verified: true)
      new_user2 = User.create(email: "sample2@example.com", password: "Qweasd12!", phone_verified: true)
      new_user3 = User.create(email: "sample3@example.com", password: "Qweasd12!", phone_verified: true)

      user_access.referred_users << new_user1.to_param
      user_access.referred_users << new_user2.to_param
      user_access.referred_users << new_user3.to_param

      user_access.claim_plus_access!
      user_access.reload

      expect(user_access.model).to eq(:plus)
      expect(user_access.model_updated_at).to eq(Time.zone.today)
    end

    it 'does not set the account model to be plus on non successful referral' do
      user_access.save!
      new_user1 = User.create(email: "sample1@example.com", password: "Qweasd12!", phone_verified: true)
      new_user2 = User.create(email: "sample2@example.com", password: "Qweasd12!", phone_verified: true)
      new_user3 = User.create(email: "sample3@example.com", password: "Qweasd12!")

      user_access.referred_users << new_user1.to_param
      user_access.referred_users << new_user2.to_param
      user_access.referred_users << new_user3.to_param

      user_access.claim_plus_access!
      user_access.reload

      expect(user_access.model).to eq(:free)
      expect(user_access.model_updated_at).to be_nil
    end
  end
end
