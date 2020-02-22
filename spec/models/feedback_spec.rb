require 'rails_helper'

RSpec.describe Feedback, type: :model do
  let(:valid_attr) { { content: "I like this app" } }
  let(:feedback)   { described_class.new(valid_attr) }

  describe "validations" do
    it 'is a valid feedback' do
      expect(feedback).to be_valid
    end

    it 'does not allow empty / blank content' do
      feedback.content = '     '
      expect(feedback).not_to be_valid
    end

    it 'does not allow long character for content' do
      feedback.content = 'a' * 256
      expect(feedback).not_to be_valid
    end
  end
end
