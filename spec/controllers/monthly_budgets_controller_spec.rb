require 'rails_helper'

RSpec.describe MonthlyBudgetsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # monthly_budget. As you add validations to monthly_budget, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes)   { { month: Date.new(1992, 3, 28).to_s, prev_month_bal_planned: 300, prev_month_bal_actual: 400 } }
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
      expect(response_body).to eq(1992.to_s => { 3.to_s => { "Expense" => { category.to_param => { "actual" => 0, "id" => cash_flow.to_param, "logs" => [], "planned" => 1000.0 } }, "prev_month_bal_actual" => 400.0, "prev_month_bal_planned" => 300.0 } })
    end
  end

  describe "PUT #update" do
    before { monthly_budget.save! }

    let(:new_attributes) do
      { prev_month_bal_planned: 100, prev_month_bal_actual: 200 }
    end

    context "with valid params" do
      it "updates the requested monthly_budget" do
        put :update, params: { user_id: user.to_param, id: monthly_budget.to_param, monthly_budget: new_attributes }, session: valid_session
        monthly_budget.reload
        expect(monthly_budget.prev_month_bal_planned).to eq new_attributes[:prev_month_bal_planned]
        expect(monthly_budget.prev_month_bal_actual).to eq new_attributes[:prev_month_bal_actual]
      end

      it "renders a JSON response with the monthly_budget" do
        put :update, params: { user_id: user.to_param, id: monthly_budget.to_param, monthly_budget: new_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      it "does not update month" do
        put :update, params: { user_id: user.to_param, id: monthly_budget.to_param, monthly_budget: { month: Time.zone.today } }, session: valid_session
        monthly_budget.reload
        expect(monthly_budget.month).to eq Date.new(1992, 3, 1)
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the monthly_budget for invalid date" do
        put :update, params: { user_id: user.to_param, id: Date.new(1992, 3, 1), monthly_budget: new_attributes }, session: valid_session
        monthly_budget.reload
        expect(response).to have_http_status(:bad_request)
        expect(monthly_budget.prev_month_bal_planned).to eq valid_attributes[:prev_month_bal_planned]

        response_body = JSON.parse(response.body)
        expect(response_body["message"]).to eq("Params: id should be of format MMYYYY")
      end

      it "renders a JSON response with errors for the monthly_budget for invalid params" do
        put :update, params: { user_id: user.to_param, id: monthly_budget.to_param, monthly_budget: { prev_month_bal_planned: "test" } }, session: valid_session
        monthly_budget.reload
        expect(response).to have_http_status(:unprocessable_entity)
        expect(monthly_budget.prev_month_bal_planned).to eq valid_attributes[:prev_month_bal_planned]

        response_body = JSON.parse(response.body)
        expect(response_body["prev_month_bal_planned"]).to eq(["is not a number"])
      end
    end
  end

  describe "GET #all_financial_years" do
    it "returns a success response" do
      get :all_financial_years, params: { user_id: user.to_param }, session: valid_session
      expect(response).to be_successful
    end

    it "returns null response if there are no monthly_budgets" do
      expect(user.monthly_budgets.count).to eq 0
      get :all_financial_years, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body).to eq []
    end

    it "returns 3 years if monthly_budgets crosses the year" do
      user.monthly_budgets.create(month: Date.new(1991, 3, 31).to_s)
      user.monthly_budgets.create(month: Date.new(1992, 4, 1).to_s)
      get :all_financial_years, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body).to eq [1990, 1991, 1992]
    end

    it "returns 1 years if monthly_budgets with the year" do
      user.monthly_budgets.create(month: Date.new(1992, 4, 1).to_s)
      user.monthly_budgets.create(month: Date.new(1993, 3, 31).to_s)
      get :all_financial_years, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body).to eq [1992]
    end
  end
end
