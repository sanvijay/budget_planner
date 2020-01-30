require 'rails_helper'

RSpec.describe Benefit, type: :model do
  let(:user)       { User.new(email: "sample@example.com") }
  let(:valid_attr) { { title: "80C", value: 1000 } }
  let(:benefit)      { user.benefits.build(valid_attr) }

  describe "validations" do
    it 'does not create record without parent' do
      expect { described_class.create(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'is a valid benefit' do
      expect(benefit).to be_valid
    end

    it 'does not allow empty / blank title' do
      benefit.title = '     '
      expect(benefit).not_to be_valid
    end

    it 'does not allow long character for title' do
      benefit.title = 'a' * 256
      expect(benefit).not_to be_valid
    end

    it 'does not allow empty value for value' do
      benefit.value = '     '
      expect(benefit).not_to be_valid
    end

    it 'does not allow non-numeric character for value' do
      benefit.value = 'a'
      expect(benefit).not_to be_valid
    end

    it 'sets the precision value to 2 decimals' do
      benefit.value = 1234.5678
      benefit.save
      expect(benefit.reload.value).to eq 1234.57
    end
  end

  describe "#category" do
    before { user.save!; benefit.save! } # rubocop:disable Style/Semicolon

    let(:category1) { user.categories.create!(title: "Test 1", type: "Income") }
    let(:category2) { user.categories.create!(title: "Test 2", type: "Income") }
    let(:category3) { user.categories.create!(title: "Test 3", type: "Income") }

    it "returns the categories that is created" do
      category1.benefit_id = benefit.id
      category2.benefit_id = benefit.id
      category3

      expect(user.categories.count).to eq 3
      expect(benefit.categories.count).to eq 2
    end
  end
end
