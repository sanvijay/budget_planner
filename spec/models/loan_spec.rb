require 'rails_helper'

RSpec.describe Loan, type: :model do
  let(:user)           { User.create(email: "sample@example.com", password: "Qweasd12!") }
  let(:user_profile)   { user.build_user_profile(first_name: "Bike", last_name: "Racer", dob: Date.new(1992, 3, 28), gender: "Male") }
  let(:loan)           { user.loans.build(valid_attr) }

  let(:valid_attr) do
    {
      description: "Bike",
      value: 1000,
      emi: 10,
      start_date: Time.zone.today,
      end_date: Time.zone.today + 1
    }
  end

  before { user_profile.save! }

  describe "validations" do
    it 'does not create record without parent' do
      expect { described_class.create(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'is a valid loan' do
      expect(loan).to be_valid
    end

    context "with description" do
      it 'does not allow empty value' do
        loan.description = '     '
        expect(loan).not_to be_valid
      end

      it 'does not allow long character' do
        loan.description = 'a' * 256
        expect(loan).not_to be_valid
      end
    end

    context "with value" do
      it 'does not allow empty value' do
        loan.value = '     '
        expect(loan).not_to be_valid
      end

      it 'sets the precision to 2 decimals' do
        loan.value = 1234.5678
        loan.save
        expect(loan.reload.value).to eq 1234.57
      end

      it 'does not allow non-numeric character' do
        loan.value = 'a'
        expect(loan).not_to be_valid
      end
    end

    context "with start_date and end_date" do
      it 'does not allow empty value for start_date' do
        loan.start_date = '     '
        expect(loan).not_to be_valid

        loan.start_date = nil
        expect(loan).not_to be_valid
      end

      it 'does not allow empty value for end_date' do
        loan.end_date = '     '
        expect(loan).not_to be_valid

        loan.end_date = nil
        expect(loan).not_to be_valid
      end

      it 'does not allow non-date for start_date' do
        loan.start_date = 'a'
        expect(loan).not_to be_valid
      end

      it 'does not allow non-date for end_date' do
        loan.end_date = 'a'
        expect(loan).not_to be_valid
      end

      pending 'converts to date on assigning integer - start_date' do
        loan.start_date = 1990_12_12 # rubocop:disable Style/NumericLiterals
        expect(loan).to be_valid
        expect(loan.start_date).to eq Date.new(1990, 12, 31)
      end

      pending 'converts to date on assigning integer - end_date' do
        loan.end_date = 1990_12_12 # rubocop:disable Style/NumericLiterals
        expect(loan).to be_valid
        expect(loan.end_date).to eq Date.new(1990, 12, 31)
      end

      it 'only allows start_date < end_date' do
        loan.start_date = Time.zone.today + 1
        loan.end_date = Time.zone.today

        expect(loan).not_to be_valid
      end

      it 'does not allow start_date = end_date' do
        loan.start_date = Time.zone.today
        loan.end_date = Time.zone.today

        expect(loan).not_to be_valid
      end
    end

    context "with categories and expected cash flows" do
      it "does not allow to create a record if category with same title is present" do
        user.save!
        user.categories.create!(title: valid_attr[:description], type: 'EMI')

        expect(loan).not_to be_valid
        expect(loan.errors.messages[:title][0]).to eq "can't have description with already existing category"
      end
    end
  end

  describe "call backs" do
    before { user.save! }

    it "creates category if not present" do
      expect { loan.save! }.to change { user.categories.count }.by(1)
      expect(user.categories.last.loan).to eq loan
    end

    pending "should not create loan if category fails to create" do
      user.categories.create!(title: valid_attr[:description], type: 'EMI')
      expect { loan.save(validate: false) }.to raise_exception(Mongoid::Errors::Validations)
      expect(user.loans.count).to eq 0
    end

    it "creates expected cashflows"
    it "creates multiple expected cashflows for longer period"
    it "should not create loan and category if expected cashflows fails to create"
  end

  describe "scope" do
    before do
      user.save!
      user.loans.create!(description: "Loan 1", value: 100, emi: 10, start_date: Date.new(2020, 4, 1), end_date: Date.new(2020, 4, 30))
    end

    it "brings loan of that financial year for during_financial_year" do
      expect(user.loans.during_financial_year(2020).count).to eq 1
    end

    it "does not brings loan of financial year if not present for during_financial_year" do
      expect(user.loans.during_financial_year(2019).count).to eq 0
    end
  end

  describe "#category" do
    it "returns the category that is created" do
      loan.save!
      expect(loan.category).to eq user.categories.last
      expect(loan.category).to eq user.categories.find_by(loan_id: loan.id)
    end
  end

  describe "#planned_cash_flow" do
    it "returns the planned amount for this loan" do
      loan.save!
      expect(loan.planned_cash_flow).to eq(valid_attr[:emi] * 1) # 1 month
    end

    it "returns the value that is calculated for that period even after changes"
    it "does not compute the value that is not in that period"
  end

  describe "#actual_cash_flow" do
    let(:monthly_budget)       { user.monthly_budgets.build(month: Time.zone.today) }
    let(:account)              { user.accounts.create(name: "Food Card") }
    let(:log_attr)             { { description: "Test", category_id: loan.category.id, account_id: account.id, value: 100, spent_on: Time.zone.now } }
    let(:actual_cash_flow_log) { monthly_budget.actual_cash_flow_logs.build(log_attr) }

    it "returns 0 where there are no expenses tracked for this loan" do
      loan.save!
      expect(loan.actual_cash_flow).to eq 0
    end

    it "returns the value tracked for that loan" do
      monthly_budget.save!
      loan.save!
      actual_cash_flow_log.save!
      expect(loan.actual_cash_flow).to eq 100
    end

    it "does not compute the value that is not in that period"
  end
end
