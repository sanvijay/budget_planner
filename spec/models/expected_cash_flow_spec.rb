require 'rails_helper'

RSpec.describe ExpectedCashFlow, type: :model do
  let(:user)             { User.create(email: "sample@example.com") }
  let(:category)         { user.categories.create(title: "House Rent", type: "Expense") }
  let(:monthly_budget)   { user.monthly_budgets.build(month: Date.today) }
  let(:expected_cash_flow) { monthly_budget.expected_cash_flows.build(category_id: category.id, value: 1000) }

  let(:valid_attr) { { category_id: category.id, value: 1000 } }

  describe "validations" do
    it 'is a valid expected_cash_flow' do
      expect(expected_cash_flow).to be_valid
    end

    context "with category_id" do
      it 'does not allow empty value' do
        expected_cash_flow.category_id = '     '
        expect(expected_cash_flow).not_to be_valid
      end

      it 'does not allow character' do
        expected_cash_flow.category_id = 'a'
        expect(expected_cash_flow).not_to be_valid
      end

      it 'does not allow integer' do
        expected_cash_flow.category_id = 1
        expect(expected_cash_flow).not_to be_valid
      end

      it "does not allow duplicate category" do
        duplicate_expected_cash_flow = monthly_budget.expected_cash_flows.build(category_id: category.id, value: 1000)
        expected_cash_flow.save
        expect(duplicate_expected_cash_flow).not_to be_valid
      end

      it 'does not allow non-existing category of this user' do
        new_category = User.create(email: "sample2@example.com").categories.create(title: "House Rent", type: "Expense")
        expect(new_category.id).not_to eq category.id

        expected_cash_flow.category_id = new_category.id
        expect(expected_cash_flow).not_to be_valid
      end
    end

    context "with value" do
      it 'does not allow empty value' do
        expected_cash_flow.value = '     '
        expect(expected_cash_flow).not_to be_valid
      end

      it 'sets the precision to 2 decimals' do
        expected_cash_flow.value = 1234.5678
        expected_cash_flow.save
        expect(expected_cash_flow.reload.value).to eq 1234.57
      end

      it 'does not allow non-numeric character' do
        expected_cash_flow.value = 'a'
        expect(expected_cash_flow).not_to be_valid
      end
    end
  end
end
