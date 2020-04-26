require 'rails_helper'

RSpec.describe Quiz, type: :model do
  let(:quiz) do
    described_class.new(
      name: "Example",
      planned_before: true,
      score: 50
    )
  end

  describe "validations" do
    it 'is a valid quiz' do
      expect(quiz).to be_valid
    end

    it 'does not allow empty / blank name' do
      quiz.name = '     '
      expect(quiz).not_to be_valid
    end

    it 'does not allow long character for name' do
      quiz.name = 'a' * 51
      expect(quiz).not_to be_valid
    end
  end
end
