require 'rails_helper'

RSpec.describe Goal, type: :model do
  let(:user) { User.new(email: "sample@example.com", password: "Qweasd12!") }
  let(:goal) { user.goals.build(valid_attr) }

  let(:valid_attr) do
    {
      description: "Bike",
      target: 1000,
      start_date: Time.zone.today,
      end_date: Time.zone.today + 1
    }
  end

  describe "validations" do
    it 'does not create record without parent' do
      expect { described_class.create(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'is a valid goal' do
      expect(goal).to be_valid
    end

    context "with score_weightage_out_of_100" do
      it 'sets score_weightage_out_of_100 by default' do
        expect(goal.score_weightage_out_of_100).to eq 100
      end

      it 'does not allow empty value' do
        goal.score_weightage_out_of_100 = '     '
        expect(goal).not_to be_valid
      end
    end

    context "with description" do
      it 'does not allow empty value' do
        goal.description = '     '
        expect(goal).not_to be_valid
      end

      it 'does not allow long character' do
        goal.description = 'a' * 256
        expect(goal).not_to be_valid
      end
    end

    context "with target" do
      it 'does not allow empty value' do
        goal.target = '     '
        expect(goal).not_to be_valid
      end

      it 'sets the precision to 2 decimals' do
        goal.target = 1234.5678
        goal.save
        expect(goal.reload.target).to eq 1234.57
      end

      it 'does not allow non-numeric character' do
        goal.target = 'a'
        expect(goal).not_to be_valid
      end
    end

    context "with start_date and end_date" do
      it 'does not allow empty value for start_date' do
        goal.start_date = '     '
        expect(goal).not_to be_valid

        goal.start_date = nil
        expect(goal).not_to be_valid
      end

      it 'does not allow empty value for end_date' do
        goal.end_date = '     '
        expect(goal).not_to be_valid

        goal.end_date = nil
        expect(goal).not_to be_valid
      end

      it 'does not allow non-date for start_date' do
        goal.start_date = 'a'
        expect(goal).not_to be_valid
      end

      it 'does not allow non-date for end_date' do
        goal.end_date = 'a'
        expect(goal).not_to be_valid
      end

      pending 'converts to date on assigning integer - start_date' do
        goal.start_date = 1990_12_12 # rubocop:disable Style/NumericLiterals
        expect(goal).to be_valid
        expect(goal.start_date).to eq Date.new(1990, 12, 31)
      end

      pending 'converts to date on assigning integer - end_date' do
        goal.end_date = 1990_12_12 # rubocop:disable Style/NumericLiterals
        expect(goal).to be_valid
        expect(goal.end_date).to eq Date.new(1990, 12, 31)
      end

      it 'only allows start_date < end_date' do
        goal.start_date = Time.zone.today + 1
        goal.end_date = Time.zone.today

        expect(goal).not_to be_valid
      end

      it 'does not allow start_date = end_date' do
        goal.start_date = Time.zone.today
        goal.end_date = Time.zone.today

        expect(goal).not_to be_valid
      end
    end

    context "with categories and expected cash flows" do
      it "does not allow to create a record if category with same title is present" do
        user.save!
        user.categories.create!(title: valid_attr[:description], type: 'EMI')

        expect(goal).not_to be_valid
        expect(goal.errors.messages[:title][0]).to eq "can't have description with already existing category"
      end
    end
  end

  describe "call backs" do
    before { user.save! }

    it "creates category if not present" do
      expect { goal.save! }.to change { user.categories.count }.by(1)
      expect(user.categories.last.goal).to eq goal
    end

    pending "should not create goal if category fails to create" do
      user.categories.create!(title: valid_attr[:description], type: 'EMI')
      expect { goal.save(validate: false) }.to raise_exception(Mongoid::Errors::Validations)
      expect(user.goals.count).to eq 0
    end

    it "creates expected cashflows"
    it "creates multiple expected cashflows for longer period"
    it "should not create goal and category if expected cashflows fails to create"
  end

  describe "scope" do
    before do
      user.save!
      user.goals.create!(description: "Goal 1", target: 10, start_date: Date.new(2020, 4, 1), end_date: Date.new(2020, 4, 30))
    end

    it "brings goal of that financial year for during_financial_year" do
      expect(user.goals.during_financial_year(2020).count).to eq 1
    end

    it "does not brings goal of financial year if not present for during_financial_year" do
      expect(user.goals.during_financial_year(2019).count).to eq 0
    end
  end

  describe "#category" do
    it "returns the category that is created" do
      goal.save!
      expect(goal.category).to eq user.categories.last
      expect(goal.category).to eq user.categories.find_by(goal_id: goal.id)
    end
  end

  describe "#planned_cash_flow" do
    it "returns the planned amount for this goal" do
      goal.save!
      expect(goal.planned_cash_flow).to eq valid_attr[:target]
    end

    it "returns the value that is calculated for that period even after changes"
    it "does not compute the value that is not in that period"
  end

  describe "#actual_cash_flow" do
    let(:monthly_budget)       { user.monthly_budgets.build(month: Time.zone.today) }
    let(:log_attr)             { { description: "Test", category_id: goal.category.id, value: 100, spent_on: Time.zone.now } }
    let(:actual_cash_flow_log) { monthly_budget.actual_cash_flow_logs.build(log_attr) }

    it "returns 0 where there are no expenses tracked for this goal" do
      goal.save!
      expect(goal.actual_cash_flow).to eq 0
    end

    it "returns the value tracked for that goal" do
      monthly_budget.save!
      goal.save!
      actual_cash_flow_log.save!
      expect(goal.actual_cash_flow).to eq 100
    end

    it "does not compute the value that is not in that period"
  end
end
