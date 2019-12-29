require 'rails_helper'

RSpec.describe Asset, type: :model do
  let(:user)       { User.new(email: "sample@example.com") }
  let(:valid_attr) { { title: "House", value: 1000 } }
  let(:asset)      { user.assets.build(valid_attr) }

  describe "validations" do
    it 'asset should not be valid without parent' do
      expect { described_class.create(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'asset should be valid' do
      expect(asset).to be_valid
    end

    it 'title should be present' do
      asset.title = '     '
      expect(asset).not_to be_valid
    end

    it 'title should not be too long' do
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
end
