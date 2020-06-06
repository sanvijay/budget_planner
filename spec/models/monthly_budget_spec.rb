require 'rails_helper'

RSpec.describe MonthlyBudget, type: :model do
  let(:user)           { User.create(email: "sample@example.com", password: "Qweasd12!") }
  let(:monthly_budget) { user.monthly_budgets.build(month: Time.zone.today + 1.day, prev_month_bal_planned: 300, prev_month_bal_actual: 400) }
  let(:user_profile)   { user.build_user_profile(first_name: "Bike", last_name: "Racer", dob: Date.new(1992, 3, 28), gender: "Male") }

  before { user_profile.save! }

  describe "validations" do
    it 'is invalid without user_id' do
      monthly_budget = described_class.new
      expect { monthly_budget.valid? }.to raise_error(NoMethodError)
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

      it 'returns the correct records for the scope of_the_financial_year' do
        user.monthly_budgets.create(month: Date.new(1993, 3, 28))

        expect(described_class.of_the_financial_year(1992).count).to eq 1
        expect(described_class.of_the_financial_year(1993).count).to eq 0
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

    context "with prev_month_bal_actual" do
      it "is invalid with non numeric prev_month_bal_actual" do
        monthly_budget.prev_month_bal_actual = "test"
        expect(monthly_budget).not_to be_valid
      end
    end

    context "with prev_month_bal_planned" do
      it "is invalid with non numeric prev_month_bal_planned" do
        monthly_budget.prev_month_bal_planned = "test"
        expect(monthly_budget).not_to be_valid
      end
    end

    context "with month" do
      it "does not allow duplicate monthly_budget" do
        duplicate_monthly_budget = user.monthly_budgets.build(month: Date.new(monthly_budget.month.year, monthly_budget.month.month, monthly_budget.month.day + 1))

        monthly_budget.save
        expect(duplicate_monthly_budget.save).to be_falsey
      end

      it "allows duplicate monthly_budget for different users" do
        user2 = User.create(email: "sample2@example.com", password: "Qweasd12!")
        user2.create_user_profile(first_name: "Bike", last_name: "Racer", dob: Date.new(1992, 3, 28), gender: "Male")
        duplicate_monthly_budget = user2.monthly_budgets.build(month: monthly_budget.month)

        monthly_budget.save
        expect(duplicate_monthly_budget).to be_valid
      end

      it "always save the month with day 1" do
        mon_budget1 = user.monthly_budgets.create(month: Date.new(1992, 3, 28))
        expect(mon_budget1.month).to eq Date.new(1992, 3, 1)

        mon_budget2 = user.monthly_budgets.create(month: Date.new(1992, 3, 1))
        expect(mon_budget2.month).to eq Date.new(1992, 3, 1)
      end

      it "is not a valid month budget if it is 100 years old" do
        user.user_profile.dob = Time.zone.today

        monthly_budget = user.monthly_budgets.new(month: Time.zone.today + (100 * 366).days)
        expect(monthly_budget).not_to be_valid
        expect(monthly_budget.errors[:month]).to include("too old to create budget")
      end

      it "is not a valid month budget if it is before birth" do
        user.user_profile.dob = Time.zone.today + 1.day

        monthly_budget = user.monthly_budgets.new(month: Time.zone.today)
        expect(monthly_budget).not_to be_valid
        expect(monthly_budget.errors[:month]).to include("too young to create budget")
      end
    end

    describe "associations" do
      before { monthly_budget.save! }

      it "gets deleted when user deleted" do
        expect(described_class.count).to eq 1
        user.destroy
        expect(described_class.count).to eq 0
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
