require 'rails_helper'

RSpec.describe CashFlowsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # CashFlow. As you add validations to CashFlow, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes)   { { category_id: category.id, planned: 1000 } }
  let(:invalid_attributes) { { category_id: "     ", planned: "test" } }

  let(:user)               { User.create(email: "sample@example.com", password: "Qweasd12!") }
  let(:category)           { user.categories.create(title: "House Rent", type: "Expense") }
  let(:monthly_budget)     { user.monthly_budgets.build(month: Time.zone.today.to_s) }
  let(:cash_flow)          { monthly_budget.cash_flows.build(valid_attributes) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AssetsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "POST #create" do
    before { monthly_budget.save! }

    context "with valid params" do
      it "creates a new Expected CashFlow" do
        before_count = monthly_budget.cash_flows.count
        post :create, params: { user_id: user.to_param, monthly_budget_id: monthly_budget.to_param, cash_flow: valid_attributes }, session: valid_session
        monthly_budget.reload
        after_count = monthly_budget.cash_flows.count

        expect(after_count - before_count).to eq 1
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      it "creates the monthly_budget if it is not already present" do
        before_count = MonthlyBudget.count
        post :create, params: { user_id: user.to_param, monthly_budget_id: '031992', cash_flow: valid_attributes }, session: valid_session
        after_count = MonthlyBudget.count

        expect(after_count - before_count).to eq 1
      end
    end

    context "with invalid params" do
      it "returns non-success response" do
        post :create, params: { user_id: user.to_param, monthly_budget_id: 'test', cash_flow: valid_attributes }, session: valid_session
        expect(response).not_to be_successful

        response_body = JSON.parse(response.body)
        expect(response_body['message']).to eq 'Params: monthly_budget_id should be of format MMYYYY'
      end

      it "renders a JSON response with errors for the new cash_flow with invalid category id" do
        post :create, params: { user_id: user.to_param, monthly_budget_id: monthly_budget.to_param, cash_flow: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:bad_request)

        response_body = JSON.parse(response.body)
        expect(response_body['message']).to eq 'category_id should be valid'
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      it "renders a JSON response with errors for the new cash_flow" do
        post :create, params: { user_id: user.to_param, monthly_budget_id: monthly_budget.to_param, cash_flow: { category_id: category.id, planned: "test" } }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "POST create_batch" do
    it "creates a batch of expected cash_flows" do
      before_count = user.monthly_budgets.count
      post :create_batch, params: { user_id: user.to_param, monthly_budget_id: monthly_budget.to_param, cash_flow: { from: "1992-03-28", to: "1993-03-28", value: 1000, category_id: category.id } }, session: valid_session
      after_count = user.reload.monthly_budgets.count

      expect(after_count - before_count).to eq 13
      expect(response).to have_http_status(:created)
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end
  end
end
