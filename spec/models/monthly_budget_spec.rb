require 'rails_helper'

RSpec.describe MonthlyBudget, type: :model do
  let(:user) { User.new(email: "sample@example.com") }
  let(:monthly_budget) { user.monthly_budgets.build(month: Date.new(1992, 3, 28)) }

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
        expect(described_class.of_the_year(monthly_budget.month.year).count).to eq 1
        expect(described_class.of_the_year(monthly_budget.month.year + 1).count).to eq 0
      end

      it 'returns the correct records for the scope of_the_month' do
        expect(described_class.of_the_month(monthly_budget.month).count).to eq 1
        expect(described_class.of_the_month(monthly_budget.month + 31.days).count).to eq 0
      end

      it 'returns the correct records for the scope of_period' do
        expect(described_class.of_period(monthly_budget.month, monthly_budget.month).count).to eq 1
        expect(described_class.of_period(monthly_budget.month + 31.days, monthly_budget.month + 31).count).to eq 0
        expect(described_class.of_period(monthly_budget.month, monthly_budget.month - 31).count).to eq 0
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
        duplicate_monthly_budget = user.monthly_budgets.build(month: Date.new(monthly_budget.month.year, monthly_budget.month.month, monthly_budget.month.day + 1))

        monthly_budget.save
        expect(duplicate_monthly_budget.save).to be_falsey
      end

      it "allows duplicate monthly_budget for different users" do
        user2 = User.create(email: "sample2@example.com")
        duplicate_monthly_budget = user2.monthly_budgets.build(month: monthly_budget.month)

        monthly_budget.save
        expect(duplicate_monthly_budget).to be_valid
      end

      it "always save the month with day 1" do
        user.save!
        mon_budget1 = user.monthly_budgets.create(month: Date.new(1992, 3, 28))
        expect(mon_budget1.month).to eq Date.new(1992, 3, 1)

        mon_budget2 = user.monthly_budgets.create(month: Date.new(1992, 3, 1))
        expect(mon_budget2.month).to eq Date.new(1992, 3, 1)
      end
    end

    describe "#to_param" do
      it "prepend 0 if month is single digit" do
        monthly_budget = described_class.new(month: Date.new(1992, 3, 1))
        expect(monthly_budget.to_param).to eq '031992'
      end

      it "leaves the month as it is if month is 2 digit" do
        monthly_budget = described_class.new(month: Date.new(1992, 12, 1))
        expect(monthly_budget.to_param).to eq '121992'
      end
    end
  end
end
