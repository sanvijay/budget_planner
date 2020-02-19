require 'rails_helper'

RSpec.describe CashFlow, type: :model do
  let(:user)             { User.create(email: "sample@example.com", password: "Qweasd12!") }
  let(:category)         { user.categories.create(title: "House Rent", type: "Expense") }
  let(:monthly_budget)   { user.monthly_budgets.build(month: Date.today) }
  let(:cash_flow)        { monthly_budget.cash_flows.build(category_id: category.id, planned: 1000) }

  let(:valid_attr) { { category_id: category.id, planned: 1000 } }

  describe "validations" do
    it 'is a valid cash_flow' do
      expect(cash_flow).to be_valid
    end

    context "with category_id" do
      it 'does not allow empty planned' do
        cash_flow.category_id = '     '
        expect(cash_flow).not_to be_valid
      end

      it 'does not allow character' do
        cash_flow.category_id = 'a'
        expect(cash_flow).not_to be_valid
      end

      it 'does not allow integer' do
        cash_flow.category_id = 1
        expect(cash_flow).not_to be_valid
      end

      it "does not allow duplicate category" do
        duplicate_cash_flow = monthly_budget.cash_flows.build(category_id: category.id, planned: 1000)
        cash_flow.save
        expect(duplicate_cash_flow).not_to be_valid
      end

      it 'does not allow non-existing category of this user' do
        new_category = User.create(email: "sample2@example.com", password: "Qweasd12!").categories.create(title: "House Rent", type: "Expense")
        expect(new_category.id).not_to eq category.id

        cash_flow.category_id = new_category.id
        expect(cash_flow).not_to be_valid
      end
    end

    context "with planned" do
      it 'does not allow empty planned' do
        cash_flow.planned = '     '
        expect(cash_flow).not_to be_valid
      end

      it 'sets the precision to 2 decimals' do
        cash_flow.planned = 1234.5678
        cash_flow.save
        expect(cash_flow.reload.planned).to eq 1234.57
      end

      it 'does not allow non-numeric character' do
        cash_flow.planned = 'a'
        expect(cash_flow).not_to be_valid
      end
    end

    context "with actual" do
      before do
        monthly_budget.save!
        cash_flow.save!
      end

      it 'returns 0 when there are no logs' do
        expect(cash_flow.actual).to eq 0
      end

      it 'returns the sum when there are logs' do
        monthly_budget.actual_cash_flow_logs.create!(category_id: category.id, value: 1000, spent_for: Time.now, description: "Test")
        monthly_budget.actual_cash_flow_logs.create!(category_id: category.id, value: 1000, spent_for: Time.now, description: "Test")

        expect(cash_flow.actual).to eq 2000.0
      end
    end
  end
end
