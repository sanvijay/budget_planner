require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:user) { User.new(email: "sample@example.com") }
  let(:category) { user.categories.build(valid_attr) }

  let(:valid_attr) { { title: "Test", type: "Income" } }

  describe "validations" do
    it 'does not create record without parent' do
      expect { described_class.create(valid_attr) }.to raise_exception(Mongoid::Errors::NoParent)
    end

    it 'is valid' do
      expect(category).to be_valid
    end

    context "with title" do
      it 'does not allow empty value' do
        category.title = '     '
        expect(category).not_to be_valid
      end

      it 'does not allow long character' do
        category.title = 'a' * 256
        expect(category).not_to be_valid
      end

      it "does not allow duplicate category" do
        duplicate_category = category.dup
        duplicate_category.title = category.title.upcase
        user.categories << duplicate_category

        category.save
        expect(duplicate_category).not_to be_valid
      end

      it "allows duplicate category for different super category" do
        duplicate_category = category.dup
        duplicate_category.title = category.title
        duplicate_category.type = "Expense"
        user.categories << duplicate_category

        category.save
        expect(duplicate_category).to be_valid
      end
    end

    context "with type" do
      it 'does not allow empty value' do
        category.type = '     '
        expect(category).not_to be_valid
      end

      it 'does not allow strings other than SUPER_CATEGORY' do
        category.type = 'a'
        expect(category).not_to be_valid
      end
    end

    context "with category scope" do
      before do
        user.save
        user.categories.create(title: "Test Income", type: "Income")
        user.categories.create(title: "Test Expense", type: "Expense")
        user.categories.create(title: "Test EMI", type: "EMI")
        user.categories.create(title: "Test EquityInvestment", type: "EquityInvestment")
        user.categories.create(title: "Test DebtInvestment", type: "DebtInvestment")
      end

      Category::SUPER_CATEGORY.values.each do |cat|
        scope_method = "by_#{cat.underscore}".to_sym
        it "##{scope_method}" do
          filtered_category = user.categories.send(scope_method)

          expect(filtered_category.count).to eq 1
          expect(filtered_category.first.title).to eq "Test #{cat}"
        end
      end
    end
  end
end
