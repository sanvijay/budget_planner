require 'rails_helper'

RSpec.describe CustomRule, type: :model do
  let(:user)         { User.new(email: "sample@example.com", password: "Qweasd12!") }
  let(:user_profile) { user.build_user_profile(valid_user_profile_attr) }
  let(:custom_rule)  { user.build_custom_rule(valid_attr) }

  let(:valid_attr) do
    {}
  end

  let(:valid_user_profile_attr) do
    {
      first_name: "Bike",
      last_name: "Racer",
      dob: Time.zone.today - 1.day,
      gender: "Male"
    }
  end

  describe "validations without user_profile" do
    it 'is not a valid custom_rule' do
      expect(custom_rule).not_to be_valid
      expect(custom_rule.errors[:user_profile]).to include "should be created"
    end
  end

  describe "validations" do
    before { user_profile.save! }

    it 'is a valid custom_rule' do
      expect(custom_rule).to be_valid
    end

    it 'does not allow empty value for outflow_split_percentage' do
      expect { custom_rule.outflow_split_percentage = '     ' }.to raise_exception(Mongoid::Errors::InvalidValue)
    end

    it 'sets the outflow_split_percentage by default' do
      custom_rule.outflow_split_percentage = nil
      expect(custom_rule).to be_valid
      expect(custom_rule.outflow_split_percentage).not_to be_nil
    end

    it 'does not allow empty value for emergency_corpus' do
      custom_rule.emergency_corpus = '     '
      expect(custom_rule).to be_valid
      expect(custom_rule.emergency_corpus).to eq 0.0
    end

    it 'does not allow empty value for current_emergency_corpus' do
      custom_rule.current_emergency_corpus = '     '
      expect(custom_rule).to be_valid
      expect(custom_rule.current_emergency_corpus).to eq 0.0
    end

    it 'does not allow empty value for emergency_corpus_score_weightage_out_of_100' do
      custom_rule.emergency_corpus_score_weightage_out_of_100 = '     '
      expect(custom_rule).not_to be_valid
    end

    it 'does not allow empty value for outflow_split_score_weightage_out_of_100' do
      custom_rule.outflow_split_score_weightage_out_of_100 = '     '
      expect(custom_rule).not_to be_valid
    end

    it 'does not allow invalid keys for outflow_split_percentage' do
      custom_rule.outflow_split_percentage = { test: 123 }
      expect(custom_rule).not_to be_valid
      custom_rule.outflow_split_percentage = { income: 123 }
      expect(custom_rule).not_to be_valid
      expect(custom_rule.errors[:outflow_split_percentage]).to include "should be subset of super category"
    end

    it 'allows valid keys for outflow_split_percentage' do
      custom_rule.outflow_split_percentage = { emi: 39.9, expense: 30.1, equity_investment: 15, debt_investment: 15 }
      expect(custom_rule).to be_valid
    end

    it "allows strings as values for outflow_split_percentage" do
      custom_rule.outflow_split_percentage = { emi: "40", expense: 30, equity_investment: 20, debt_investment: 10 }
      expect(custom_rule).to be_valid
    end

    it "fails if it doesn't adds up to 100 for outflow_split_percentage values" do
      custom_rule.outflow_split_percentage = { emi: 40, expense: 30, equity_investment: 10, debt_investment: 10 }
      expect(custom_rule).not_to be_valid
      expect(custom_rule.errors[:outflow_split_percentage]).to include "should add up to 100"
    end
  end

  describe "call backs" do
    before { user_profile.save! }

    it 'sets the precision to 2 decimals - emergency_corpus' do
      custom_rule.emergency_corpus = 1234.5678
      custom_rule.save
      expect(custom_rule.reload.emergency_corpus).to eq 1234.57
    end

    it 'does not sets the outflow_split_percentage if already present' do
      custom_rule.outflow_split_percentage = { emi: 30, expense: 40, equity_investment: 10, debt_investment: 20 }

      expect(custom_rule).to be_valid
      expect(custom_rule.outflow_split_percentage).to eq(emi: 30, expense: 40, equity_investment: 10, debt_investment: 20)
    end

    it 'sets the outflow_split_percentage by dob field' do
      user_profile.dob = Time.zone.today - 27.years
      user_profile.save!

      expect(custom_rule).to be_valid
      expect(custom_rule.outflow_split_percentage).to eq(emi: 40, expense: 30, equity_investment: 21.9, debt_investment: 8.1)
    end

    it 'sets the emergency_corpus by monthly_income field' do
      user_profile.monthly_income = 1000
      user_profile.save!

      expect(custom_rule).to be_valid
      expect(custom_rule.emergency_corpus).to eq 6000
    end

    it 'sets the emergency_corpus to 0 if monthly_income is nil' do
      expect(custom_rule).to be_valid
      expect(custom_rule.emergency_corpus).to eq 0
    end
  end
end
