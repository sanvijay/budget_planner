require 'rails_helper'

RSpec.describe Asset, type: :model do
  let(:user)         { User.new(email: "sample@example.com", password: "Qweasd12!") }
  let(:valid_attr)   { { title: "House", value: 1000 } }
  let(:asset)        { user.assets.build(valid_attr) }
  let(:user_profile) { user.build_user_profile(first_name: "Bike", last_name: "Racer", dob: Date.new(1990, 3, 28), gender: "Male") }

  describe "validations" do
    it 'does not create record without parent' do
      expect { described_class.create(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'is a valid asset' do
      expect(asset).to be_valid
    end

    it 'does not allow empty / blank title' do
      asset.title = '     '
      expect(asset).not_to be_valid
    end

    it 'does not allow long character for title' do
      asset.title = 'a' * 256
      expect(asset).not_to be_valid
    end

    it 'does not allow empty value for value' do
      asset.value = '     '
      expect(asset).not_to be_valid
    end

    it 'does not allow non-numeric character for value' do
      asset.value = 'a'
      expect(asset).not_to be_valid
    end

    it 'sets the precision value to 2 decimals' do
      asset.value = 1234.5678
      asset.save
      expect(asset.reload.value).to eq 1234.57
    end
  end

  describe "#categories" do
    before { user.save!; asset.save! } # rubocop:disable Style/Semicolon

    let(:category1) { user.categories.create!(title: "Test 1", type: "Income") }
    let(:category2) { user.categories.create!(title: "Test 2", type: "Income") }
    let(:category3) { user.categories.create!(title: "Test 3", type: "Income") }

    it "returns the categories that is created" do
      category1.asset_id = asset.id
      category2.asset_id = asset.id
      category3

      expect(user.categories.count).to eq 3
      expect(asset.categories.count).to eq 2
    end
  end

  describe "#inflow_category_ids" do
    before { user.save!; asset.save! } # rubocop:disable Style/Semicolon

    let(:category1) { user.categories.create!(title: "Test 1", type: "Income") }
    let(:category2) { user.categories.create!(title: "Test 2", type: "Expense") }
    let(:category3) { user.categories.create!(title: "Test 3", type: "Income") }

    it "returns the categories that is created" do
      category1.asset_id = asset.id
      category2.asset_id = asset.id
      category3

      expect(asset.inflow_category_ids.count).to eq 1
      expect(asset.inflow_category_ids).to include category1.id
    end
  end

  describe "#outflow_category_ids" do
    before { user.save!; asset.save! } # rubocop:disable Style/Semicolon

    let(:category1) { user.categories.create!(title: "Test 1", type: "Income") }
    let(:category2) { user.categories.create!(title: "Test 2", type: "Expense") }
    let(:category3) { user.categories.create!(title: "Test 3", type: "Expense") }

    it "returns the categories that is created" do
      category1.asset_id = asset.id
      category2.asset_id = asset.id
      category3

      expect(asset.outflow_category_ids.count).to eq 1
      expect(asset.outflow_category_ids).to include category2.id
    end
  end

  describe "#all_monthly_budgets" do
    let(:monthly_budget1) { user.monthly_budgets.build(month: Date.new(1992, 3, 28)) }
    let(:monthly_budget2) { user.monthly_budgets.build(month: Date.new(1993, 3, 28)) }

    before { user.save!; user_profile.save!; asset.save!; monthly_budget1.save!; monthly_budget2.save! } # rubocop:disable Style/Semicolon

    it "returns all the monthly_budgets without params" do
      mbs = asset.send(:all_monthly_budgets)
      expect(mbs.count).to eq 2
    end

    it "returns the monthly_budgets of the financial year" do
      mbs = asset.send(:all_monthly_budgets, 1992)
      expect(mbs.count).to eq 1
      expect(mbs.first.id).to eq monthly_budget2.id
    end
  end

  describe "#inflow_actual_cash_flow_logs" do
    before { user.save!; user_profile.save!; asset.save! } # rubocop:disable Style/Semicolon

    let(:account)   { user.accounts.create(name: "Food Card") }
    let(:category1) { user.categories.create!(title: "Test 1", type: "Income") }
    let(:category2) { user.categories.create!(title: "Test 2", type: "Expense") }

    let(:monthly_budget) { user.monthly_budgets.create!(month: Date.new(1992, 3, 28)) }
    let(:actual_cash_flow_log1) { monthly_budget.actual_cash_flow_logs.create!(acfl_attr1) }
    let(:actual_cash_flow_log2) { monthly_budget.actual_cash_flow_logs.create!(acfl_attr2) }

    let(:acfl_attr1) { { description: "Test1", category_id: category1.id, account_id: account.id, value: 100, spent_on: Date.new(1992, 3, 28) } }
    let(:acfl_attr2) { { description: "Test2", category_id: category2.id, account_id: account.id, value: 200, spent_on: Date.new(1992, 3, 28) } }

    it "returns 0 when there are no actual_cash_flow_logs associated" do
      expect(asset.inflow_actual_cash_flow_logs(financial_year: 1991)).to eq 0
    end

    it "returns the total for the given financial year" do
      category1.asset_id = asset.id
      category2.asset_id = asset.id

      actual_cash_flow_log1
      actual_cash_flow_log2

      expect(asset.inflow_actual_cash_flow_logs(financial_year: 1991)).to eq 100
    end

    pending "returns the total for the overall years"
  end

  describe "#outflow_actual_cash_flow_logs" do
    before { user.save!; user_profile.save!; asset.save! } # rubocop:disable Style/Semicolon

    let(:account)   { user.accounts.create(name: "Food Card") }
    let(:category1) { user.categories.create!(title: "Test 1", type: "Income") }
    let(:category2) { user.categories.create!(title: "Test 2", type: "Expense") }

    let(:monthly_budget) { user.monthly_budgets.create!(month: Date.new(1992, 3, 28)) }
    let(:actual_cash_flow_log1) { monthly_budget.actual_cash_flow_logs.create!(acfl_attr1) }
    let(:actual_cash_flow_log2) { monthly_budget.actual_cash_flow_logs.create!(acfl_attr2) }

    let(:acfl_attr1) { { description: "Test1", category_id: category1.id, account_id: account.id, value: 100, spent_on: Date.new(1992, 3, 28) } }
    let(:acfl_attr2) { { description: "Test2", category_id: category2.id, account_id: account.id, value: 200, spent_on: Date.new(1992, 3, 28) } }

    it "returns 0 when there are no actual_cash_flow_logs associated" do
      expect(asset.outflow_actual_cash_flow_logs(financial_year: 1991)).to eq 0
    end

    it "returns the total for the given financial year" do
      category1.asset_id = asset.id
      category2.asset_id = asset.id

      actual_cash_flow_log1
      actual_cash_flow_log2

      expect(asset.outflow_actual_cash_flow_logs(financial_year: 1991)).to eq 200
    end

    pending "returns the total for the overall years"
  end

  describe "#total_cost" do
    before { user.save!; user_profile.save!; asset.save! } # rubocop:disable Style/Semicolon

    let(:account) { user.accounts.create(name: "Food Card") }

    let(:category1) { user.categories.create!(title: "Test 1", type: "Income") }
    let(:category2) { user.categories.create!(title: "Test 2", type: "Expense") }

    let(:monthly_budget) { user.monthly_budgets.create!(month: Date.new(1992, 3, 28)) }
    let(:actual_cash_flow_log1) { monthly_budget.actual_cash_flow_logs.create!(acfl_attr1) }
    let(:actual_cash_flow_log2) { monthly_budget.actual_cash_flow_logs.create!(acfl_attr2) }

    let(:acfl_attr1) { { description: "Test1", category_id: category1.id, account_id: account.id, value: 100, spent_on: Date.new(1992, 3, 28) } }
    let(:acfl_attr2) { { description: "Test2", category_id: category2.id, account_id: account.id, value: 200, spent_on: Date.new(1992, 3, 28) } }

    it "returns 0 when there are no actual_cash_flow_logs associated" do
      expect(asset.outflow_actual_cash_flow_logs(financial_year: 1991)).to eq 0
    end

    it "returns the total for the given financial year" do
      category1.asset_id = asset.id
      category2.asset_id = asset.id

      actual_cash_flow_log1
      actual_cash_flow_log2

      expect(asset.total_cost(financial_year: 1991)).to eq(inflow: 100.0, outflow: 200.0)
    end
  end
end
