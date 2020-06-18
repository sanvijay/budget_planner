require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:user)     { User.new(email: "sample@example.com", password: "Qweasd12!") }
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

    context "with goal" do
      it "doesn't allow goal of another user" do
        user2 = User.create(email: "example@sample.com")
        goal = user2.goals.build(
          description: "Bike",
          target: 1000,
          start_date: Time.zone.today,
          end_date: Time.zone.today + 1
        )

        category.goal_id = goal.id
        category.save
        expect(category).not_to be_valid
      end

      it "is valid with valid current user goal" do
        goal = user.goals.build(
          description: "Bike",
          target: 1000,
          start_date: Time.zone.today,
          end_date: Time.zone.today + 1
        )

        category.goal_id = goal.id
        category.save
        expect(category).to be_valid
      end

      it "returns nil for empty goal_id" do
        category.save
        expect(category.goal).to be_nil
      end
    end

    context "with loan" do
      it "doesn't allow loan of another user" do
        category.type = "Expense"
        user2 = User.create(email: "example@sample.com")
        loan = user2.loans.build(
          description: "Bike",
          value: 1000,
          emi: 1000,
          start_date: Time.zone.today,
          end_date: Time.zone.today + 1
        )

        category.loan_id = loan.id
        category.save
        expect(category).not_to be_valid
      end

      it "is valid with valid current user loan" do
        category.type = "Expense"
        loan = user.loans.build(
          description: "Bike",
          value: 1000,
          emi: 1000,
          start_date: Time.zone.today,
          end_date: Time.zone.today + 1
        )

        category.loan_id = loan.id
        category.save
        expect(category).to be_valid
      end

      it "is not valid with Income category type" do
        category.type = "Income"
        loan = user.loans.build(
          description: "Bike",
          value: 1000,
          emi: 1000,
          start_date: Time.zone.today,
          end_date: Time.zone.today + 1
        )

        category.loan_id = loan.id
        category.save
        expect(category).not_to be_valid
      end

      it "returns nil for empty loan_id" do
        category.save
        expect(category.loan).to be_nil
      end
    end

    context "with asset" do
      it "doesn't allow asset of another user" do
        user2 = User.create(email: "example@sample.com")
        asset = user2.assets.build(
          title: "Bike",
          value: 1000
        )

        category.asset_id = asset.id
        category.save
        expect(category).not_to be_valid
      end

      it "is valid with valid current user asset" do
        asset = user.assets.build(
          title: "Bike",
          value: 1000
        )

        category.asset_id = asset.id
        category.save
        expect(category).to be_valid
      end

      it "returns nil for empty asset_id" do
        category.save
        expect(category.asset).to be_nil
      end
    end

    context "with benefit" do
      it "doesn't allow benefit of another user" do
        user2 = User.create(email: "example@sample.com")
        benefit = user2.benefits.build(
          title: "Bike",
          value: 1000
        )

        category.benefit_id = benefit.id
        category.save
        expect(category).not_to be_valid
      end

      it "is valid with valid current user benefit" do
        category.type = "EquityInvestment"
        benefit = user.benefits.build(
          title: "Bike",
          value: 1000
        )

        category.benefit_id = benefit.id
        category.save
        expect(category).to be_valid
      end

      it "is not valid with Income category type" do
        category.type = "Income"
        benefit = user.benefits.build(
          title: "Bike",
          value: 1000
        )

        category.benefit_id = benefit.id
        category.save
        expect(category).not_to be_valid
      end

      it "returns nil for empty benefit_id" do
        category.save
        expect(category.benefit).to be_nil
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
