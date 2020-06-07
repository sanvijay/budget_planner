require 'rails_helper'

RSpec.describe Account, type: :model do
  let(:user)         { User.new(email: "sample@example.com", password: "Qweasd12!") }
  let(:valid_attr)   { { name: "Food card" } }
  let(:account)      { user.accounts.build(valid_attr) }

  describe "validations" do
    it 'does not create record without parent' do
      expect { described_class.create(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'is a valid account' do
      expect(account).to be_valid
    end

    it 'does not allow empty / blank name' do
      account.name = '     '
      expect(account).not_to be_valid
    end

    it 'does not allow long character for name' do
      account.name = 'a' * 51
      expect(account).not_to be_valid
    end
  end
end
