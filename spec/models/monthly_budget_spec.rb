require 'rails_helper'

RSpec.describe MonthlyBudget, type: :model do
  let(:user) { User.new(email: "sample@example.com") }
  let(:monthly_budget) { user.monthly_budgets.build(month: Date.today) }

  describe "validations" do
    it 'is invalid without user_id' do
      monthly_budget = described_class.new
      expect(monthly_budget).not_to be_valid
      expect(monthly_budget.errors.messages[:user]).to eq(["can't be blank"])
    end

    it 'is valid with user_id' do
      expect(monthly_budget).to be_valid
    end

    context "with scope" do
      before { monthly_budget.save! }

      it 'returns the correct records for the scope of_the_year' do
        expect(described_class.of_the_year(Date.today.year).count).to eq 1
        expect(described_class.of_the_year(Date.today.year + 1).count).to eq 0
      end
    end

    context "with month" do
      it 'does not allow empty value' do
        monthly_budget.month = '     '
        expect(monthly_budget).not_to be_valid
      end

      it 'does not allow other characters' do
        monthly_budget.month = 'a'
        expect(monthly_budget).not_to be_valid
      end

      it "does not allow duplicate monthly_budget" do
        duplicate_category = monthly_budget.dup
        duplicate_category.month = monthly_budget.month
        user.categories << duplicate_category

        monthly_budget.save
        expect(duplicate_category).not_to be_valid
      end

      it "allows duplicate monthly_budget for different users" do
        duplicate_category = monthly_budget.dup
        duplicate_category.month = monthly_budget.month

        user2 = User.create(email: "sample2@example.com")
        user2.categories << duplicate_category

        monthly_budget.save
        expect(duplicate_category).to be_valid
      end
    end
  end
end
