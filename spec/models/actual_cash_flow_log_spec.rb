require 'rails_helper'

RSpec.describe ActualCashFlowLog, type: :model do
  let(:user)                 { User.create(email: "sample@example.com", password: "Qweasd12!") }
  let(:category)             { user.categories.create(title: "House Rent", type: "Expense") }
  let(:monthly_budget)       { user.monthly_budgets.build(month: Date.today) }
  let(:actual_cash_flow_log) { monthly_budget.actual_cash_flow_logs.build(valid_attr) }

  let(:valid_attr) { { category_id: category.id, value: 1000, spent_on: Time.now } }

  describe "validations" do
    pending 'does not create record without parent' do
      expect { described_class.create!(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'is a valid actual_cash_flow_log' do
      expect(actual_cash_flow_log).to be_valid
    end

    context "with category_id" do
      it 'does not allow empty value' do
        actual_cash_flow_log.category_id = '     '
        expect(actual_cash_flow_log).not_to be_valid
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
end
