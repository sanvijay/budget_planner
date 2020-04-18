require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  let(:user)         { User.new(email: "sample@example.com", password: "Qweasd12!") }
  let(:user_profile) { user.build_user_profile(valid_attr) }

  let(:valid_attr) do
    {
      first_name: "Bike",
      last_name: "Racer",
      dob: Time.zone.today - 1.day,
      gender: "Male",
      expense_ratio: { expense: 30, emi: 40, equity_investment: 10, debt_investment: 20 }
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
      user_profile.dob = Time.zone.today + 1.day
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

    it "does not allow empty expense_ratio" do
      user_profile.expense_ratio = nil
      expect(user_profile).not_to be_valid
    end

    it "does not allow empty array as expense_ratio" do
      user_profile.expense_ratio = {}
      expect(user_profile).not_to be_valid
      expect(user_profile.errors[:expense_ratio]).not_to eq("should adds to 100")
    end

    it "does not allow array which sums to non-100 as expense_ratio" do
      user_profile.expense_ratio = { expense: 0, emi: 10, equity_investment: 20, debt_investment: 30 }
      expect(user_profile).not_to be_valid
      expect(user_profile.errors[:expense_ratio]).not_to eq("should adds to 100")
    end

    it "does not allow array with non-4 count as expense_ratio" do
      user_profile.expense_ratio = { expense: 0, emi: 10, equity_investment: 20, debt_investment: 30, test: 200 }
      expect(user_profile).not_to be_valid
      expect(user_profile.errors[:expense_ratio]).not_to eq("should have 4 numbers")
    end

    it "is valid with string expense_ratio" do
      user_profile.expense_ratio = { expense: "39.5", emi: 10.5, equity_investment: "20", debt_investment: 30 }
      expect(user_profile).to be_valid
    end

    it "does not allow gender other than provider list" do
      ["Test", 123, Time.zone.today].each do |invalid_gender|
        user_profile.gender = invalid_gender
        expect(user_profile).not_to be_valid
      end
    end
  end

  describe "call backs" do
    it "sets the numeric string array to numeric array as expense_ratio" do
      user_profile.expense_ratio = { expense: "40", emi: 10, equity_investment: "20", debt_investment: 30 }
      user_profile.valid?
      expect(user_profile.expense_ratio).to eq(expense: 40, emi: 10, equity_investment: 20, debt_investment: 30)
    end

    it "sets the non-numeric array to numeric array as expense_ratio" do
      user_profile.expense_ratio = { expense: "test", emi: "test", equity_investment: "test", debt_investment: "test" }
      user_profile.valid?
      expect(user_profile.expense_ratio.values).to eq([0, 0, 0, 0])
    end

    it 'sets the precision only if monthly_income present' do
      user_profile.monthly_income = nil
      user_profile.save
      expect(user_profile.reload.monthly_income).to eq nil
    end

    it 'sets the precision to 2 decimals - monthly_income' do
      user_profile.monthly_income = 1234.5678
      user_profile.save
      expect(user_profile.reload.monthly_income).to eq 1234.57
    end
  end

  describe "#age" do
    it 'calculates the age' do
      user_profile.dob = Time.zone.today - 27.years
      expect(user_profile.age).to eq 27
    end

    it 'calculates the age as 0 if dob is nil' do
      user_profile.dob = nil
      expect(user_profile.age).to eq 0
    end
  end
end
