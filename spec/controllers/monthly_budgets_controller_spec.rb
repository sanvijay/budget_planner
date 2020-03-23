require 'rails_helper'

RSpec.describe MonthlyBudgetsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # monthly_budget. As you add validations to monthly_budget, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes)   { { month: Date.new(1992, 3, 28).to_s } }
  let(:invalid_attributes) { { month: "" } }

  let(:user)               { User.create(email: "sample@example.com", password: "Qweasd12!") }
  let(:category)           { user.categories.create(title: "House Rent", type: "Expense") }
  let(:monthly_budget)     { user.monthly_budgets.build(valid_attributes) }
  let(:cash_flow)          { monthly_budget.cash_flows.build(category_id: category.id, planned: 1000) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # MonthlyBudgetsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    before { monthly_budget.save! }

    it "returns a success response" do
      get :index, params: { user_id: user.to_param, financial_year: 1991 }, session: valid_session
      expect(response).to be_successful
    end

    it "returns a unsuccess response without params: year" do
      get :index, params: { user_id: user.to_param }, session: valid_session
      expect(response).not_to be_successful
      expect(response).to have_http_status(:bad_request)

      response_body = JSON.parse(response.body)
      expect(response_body["message"]).to eq("Params: financial_year is required")
    end

    it "returns a JSON response with monthly_budget and cash_flows" do
      cash_flow.save!
      get :index, params: { user_id: user.to_param, financial_year: 1991 }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body).to eq("Expense" => { category.to_param => { 1992.to_s => { 3.to_s => { "value" => 1000.0 } } } })
    end
  end
end
