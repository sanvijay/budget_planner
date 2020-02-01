require 'rails_helper'

RSpec.describe Asset, type: :model do
  let(:user)       { User.new(email: "sample@example.com", password: "Qweasd12!") }
  let(:valid_attr) { { title: "House", value: 1000 } }
  let(:asset)      { user.assets.build(valid_attr) }

  describe "validations" do
    it 'does not create record without parent' do
      expect { described_class.create(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'is a valid asset' do
      expect(asset).to be_valid
    end

    it 'does not allow empty / blank title' do
      asset.title = '     '
      expect(asset).not_to be_valid
    end

    it 'does not allow long character for title' do
      asset.title = 'a' * 256
      expect(asset).not_to be_valid
    end

    it 'does not allow empty value for value' do
      asset.value = '     '
      expect(asset).not_to be_valid
    end

    it 'does not allow non-numeric character for value' do
      asset.value = 'a'
      expect(asset).not_to be_valid
    end

    it 'sets the precision value to 2 decimals' do
      asset.value = 1234.5678
      asset.save
      expect(asset.reload.value).to eq 1234.57
    end
  end

  describe "#categories" do
    before { user.save!; asset.save! } # rubocop:disable Style/Semicolon

    let(:category1) { user.categories.create!(title: "Test 1", type: "Income") }
    let(:category2) { user.categories.create!(title: "Test 2", type: "Income") }
    let(:category3) { user.categories.create!(title: "Test 3", type: "Income") }

    it "returns the categories that is created" do
      category1.asset_id = asset.id
      category2.asset_id = asset.id
      category3

      expect(user.categories.count).to eq 3
      expect(asset.categories.count).to eq 2
    end
  end
end
