require 'rails_helper'

RSpec.describe PlannedCashFlow, type: :model do
  let(:user)             { User.create(email: "sample@example.com") }
  let(:category)         { user.categories.create(title: "House Rent", type: "Expense") }
  let(:monthly_budget)   { user.monthly_budgets.build(month: Date.today) }
  let(:planned_cash_flow) { monthly_budget.planned_cash_flows.build(category_id: category.id, value: 1000) }

  let(:valid_attr) { { category_id: category.id, value: 1000 } }

  describe "validations" do
    it 'is a valid planned_cash_flow' do
      expect(planned_cash_flow).to be_valid
    end

    context "with category_id" do
      it 'does not allow empty value' do
        planned_cash_flow.category_id = '     '
        expect(planned_cash_flow).not_to be_valid
      end

      it 'does not allow character' do
        planned_cash_flow.category_id = 'a'
        expect(planned_cash_flow).not_to be_valid
      end

      it 'does not allow integer' do
        planned_cash_flow.category_id = 1
        expect(planned_cash_flow).not_to be_valid
      end

      it "does not allow duplicate category" do
        duplicate_planned_cash_flow = monthly_budget.planned_cash_flows.build(category_id: category.id, value: 1000)
        planned_cash_flow.save
        expect(duplicate_planned_cash_flow).not_to be_valid
      end

      it 'does not allow non-existing category of this user' do
        new_category = User.create(email: "sample2@example.com").categories.create(title: "House Rent", type: "Expense")
        expect(new_category.id).not_to eq category.id

        planned_cash_flow.category_id = new_category.id
        expect(planned_cash_flow).not_to be_valid
      end
    end

    context "with value" do
      it 'does not allow empty value' do
        planned_cash_flow.value = '     '
        expect(planned_cash_flow).not_to be_valid
      end

      it 'sets the precision to 2 decimals' do
        planned_cash_flow.value = 1234.5678
        planned_cash_flow.save
        expect(planned_cash_flow.reload.value).to eq 1234.57
      end

      it 'does not allow non-numeric character' do
        planned_cash_flow.value = 'a'
        expect(planned_cash_flow).not_to be_valid
      end
    end
  end
end
