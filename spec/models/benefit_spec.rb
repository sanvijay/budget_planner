require 'rails_helper'

RSpec.describe Benefit, type: :model do
  let(:user)       { User.new(email: "sample@example.com", password: "Qweasd12!") }
  let(:valid_attr) { { title: "80C", value: 1000 } }
  let(:benefit)    { user.benefits.build(valid_attr) }

  describe "validations" do
    it 'does not create record without parent' do
      expect { described_class.create(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'is a valid benefit' do
      expect(benefit).to be_valid
    end

    it 'does not allow empty / blank title' do
      benefit.title = '     '
      expect(benefit).not_to be_valid
    end

    it 'does not allow long character for title' do
      benefit.title = 'a' * 256
      expect(benefit).not_to be_valid
    end

    it 'does not allow empty value for value' do
      benefit.value = '     '
      expect(benefit).not_to be_valid
    end

    it 'does not allow non-numeric character for value' do
      benefit.value = 'a'
      expect(benefit).not_to be_valid
    end

    it 'sets the precision value to 2 decimals' do
      benefit.value = 1234.5678
      benefit.save
      expect(benefit.reload.value).to eq 1234.57
    end
  end

  describe "#categories" do
    before { user.save!; benefit.save! } # rubocop:disable Style/Semicolon

    let(:category1) { user.categories.create!(title: "Test 1", type: "Income") }
    let(:category2) { user.categories.create!(title: "Test 2", type: "Income") }
    let(:category3) { user.categories.create!(title: "Test 3", type: "Income") }

    it "returns the categories that is created" do
      category1.benefit_id = benefit.id
      category2.benefit_id = benefit.id
      category3

      expect(user.categories.count).to eq 3
      expect(benefit.categories.count).to eq 2
    end
  end

  describe "#category_ids" do
    before { user.save!; benefit.save! } # rubocop:disable Style/Semicolon

    let(:category1) { user.categories.create!(title: "Test 1", type: "Income") }
    let(:category2) { user.categories.create!(title: "Test 2", type: "Income") }
    let(:category3) { user.categories.create!(title: "Test 3", type: "Income") }

    it "returns the categories that is created" do
      category1.benefit_id = benefit.id
      category2.benefit_id = benefit.id
      category3

      expect(benefit.category_ids.count).to eq 2
      expect(benefit.category_ids).to include category1.id
      expect(benefit.category_ids).not_to include category3.id
    end
  end

  describe "#yearly_total" do
    let(:user_profile) { user.build_user_profile(first_name: "Bike", last_name: "Racer", dob: Date.new(1990, 3, 28), gender: "Male") }
    let(:account)      { user.accounts.create(name: "Food Card") }

    let(:category1) { user.categories.create!(title: "Test 1", type: "EMI") }
    let(:category2) { user.categories.create!(title: "Test 2", type: "Expense") }

    let(:monthly_budget) { user.monthly_budgets.create!(month: Date.new(1992, 3, 28)) }
    let(:actual_cash_flow_log1) { monthly_budget.actual_cash_flow_logs.create!(acfl_attr1) }
    let(:actual_cash_flow_log2) { monthly_budget.actual_cash_flow_logs.create!(acfl_attr2) }

    let(:acfl_attr1) { { description: "Test1", category_id: category1.id, account_id: account.id, value: 100, spent_on: Date.new(1992, 3, 28) } }
    let(:acfl_attr2) { { description: "Test2", category_id: category2.id, account_id: account.id, value: 200, spent_on: Date.new(1992, 3, 28) } }

    before { user.save!; user_profile.save!; benefit.save! } # rubocop:disable Style/Semicolon

    it "returns 0 when there are no actual_cash_flow_logs associated" do
      expect(benefit.yearly_total(financial_year: 1991)).to eq 0
    end

    it "returns the total for the given financial year" do
      category1.benefit_id = benefit.id
      category2.benefit_id = benefit.id

      actual_cash_flow_log1
      actual_cash_flow_log2

      expect(benefit.yearly_total(financial_year: 1991)).to eq 300
    end
  end
end
