require 'rails_helper'

RSpec.describe ActualCashFlowLog, type: :model do
  let(:user)                 { User.create(email: "sample@example.com", password: "Qweasd12!") }
  let(:category)             { user.categories.create(title: "House Rent", type: "Expense") }
  let(:account)              { user.accounts.create(name: "Food Card") }
  let(:monthly_budget)       { user.monthly_budgets.build(month: Time.zone.today) }
  let(:actual_cash_flow_log) { monthly_budget.actual_cash_flow_logs.build(valid_attr) }
  let(:user_profile)         { user.build_user_profile(first_name: "Bike", last_name: "Racer", dob: Date.new(1990, 3, 28), gender: "Male") }

  let(:valid_attr) { { description: "Test", category_id: category.id, account_id: account.id, value: 1000, spent_on: Time.zone.now } }

  describe "validations" do
    pending 'does not create record without parent' do
      expect { described_class.create!(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'is a valid actual_cash_flow_log' do
      expect(actual_cash_flow_log).to be_valid
    end

    context "with category_id" do
      before { user_profile.save!; monthly_budget.save! } # rubocop:disable Style/Semicolon

      it 'does not allow empty value' do
        actual_cash_flow_log.category_id = '     '
        expect(actual_cash_flow_log).not_to be_valid
        expect(actual_cash_flow_log.errors[:category_id]).to include("can't be blank")
      end

      it 'does not allow character' do
        actual_cash_flow_log.category_id = 'a'
        expect(actual_cash_flow_log).not_to be_valid
      end

      it 'does not allow integer' do
        actual_cash_flow_log.category_id = 1
        expect(actual_cash_flow_log).not_to be_valid
      end

      it "allows duplicate category" do
        duplicate_cash_flow_log = monthly_budget.actual_cash_flow_logs.build(valid_attr)
        actual_cash_flow_log.save
        expect(duplicate_cash_flow_log).to be_valid
      end

      it 'does not allow non-existing category of this user' do
        new_category = User.create(email: "sample2@example.com", password: "Qweasd12!").categories.create(title: "House Rent", type: "Expense")
        expect(new_category.id).not_to eq category.id

        actual_cash_flow_log.category_id = new_category.id
        expect(actual_cash_flow_log).not_to be_valid
      end
    end

    context "with account_id" do
      it 'does not allow empty value' do
        actual_cash_flow_log.account_id = '     '
        expect(actual_cash_flow_log).not_to be_valid
      end

      it 'does not allow non-existing account of this user' do
        new_account = User.create(email: "sample2@example.com", password: "Qweasd12!").accounts.create(name: "Food Card")
        expect(new_account.id).not_to eq account.id

        actual_cash_flow_log.account_id = new_account.id
        expect(actual_cash_flow_log).not_to be_valid
        expect(actual_cash_flow_log.errors[:account_id]).to include("should belong to current user")
      end
    end

    context "with spent_on" do
      it 'does not allow empty value' do
        actual_cash_flow_log.spent_on = '     '
        expect(actual_cash_flow_log).not_to be_valid
      end

      it 'does not allow character' do
        actual_cash_flow_log.spent_on = 'a'
        expect(actual_cash_flow_log).not_to be_valid
      end

      pending 'allow integer of certain format' do
        actual_cash_flow_log.spent_on = 1
        expect(actual_cash_flow_log).to be_valid
        expect(actual_cash_flow_log.spent_on).to eq Date.new
      end
    end

    context "with value" do
      it 'does not allow empty value' do
        actual_cash_flow_log.value = '     '
        expect(actual_cash_flow_log).not_to be_valid
      end

      it 'sets the precision to 2 decimals' do
        user_profile.save!
        monthly_budget.save!
        actual_cash_flow_log.value = 1234.5678
        actual_cash_flow_log.save
        expect(actual_cash_flow_log.value).to eq 1234.57
      end

      it 'does not allow non-numeric character' do
        actual_cash_flow_log.value = 'a'
        expect(actual_cash_flow_log).not_to be_valid
      end
    end
  end

  describe "callbacks" do
    before { user_profile.save!; monthly_budget.save! } # rubocop:disable Style/Semicolon

    it "creates cash_flow if there is none" do
      expect(monthly_budget.cash_flows.count).to eq 0
      monthly_budget.actual_cash_flow_logs.create(valid_attr)

      expect(monthly_budget.cash_flows.count).to eq 1
    end

    it "creates cash_flow for the right category" do
      monthly_budget.actual_cash_flow_logs.create(valid_attr)

      expect(monthly_budget.cash_flows.first.category_id).to eq monthly_budget.actual_cash_flow_logs.first.category_id
    end

    it "does not creates cash_flow if there is one" do
      monthly_budget.cash_flows.create(category_id: category.id, planned: 1000)
      expect(monthly_budget.cash_flows.count).to eq 1
      monthly_budget.actual_cash_flow_logs.create(valid_attr)

      expect(monthly_budget.cash_flows.count).to eq 1
    end
  end
end
