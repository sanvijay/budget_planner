require 'rails_helper'

RSpec.describe Goal, type: :model do
  let(:user) { User.new(email: "sample@example.com") }
  let(:goal) { user.goals.build(valid_attr) }

  let(:valid_attr) do
    {
      description: "Bike",
      target: 1000,
      start_date: Date.today,
      end_date: Date.today + 1
    }
  end

  describe "validations" do
    it 'does not create record without parent' do
      expect { described_class.create(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'goal should be valid' do
      expect(goal).to be_valid
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
        goal.start_date = Date.today + 1
        goal.end_date = Date.today

        expect(goal).not_to be_valid
      end

      it 'does not allow start_date = end_date' do
        goal.start_date = Date.today
        goal.end_date = Date.today

        expect(goal).not_to be_valid
      end
    end
  end
end
