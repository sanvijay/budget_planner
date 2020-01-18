require 'rails_helper'

RSpec.describe CashFlowsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # CashFlow. As you add validations to CashFlow, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes)   { { category_id: category.id, value: 1000 } }
  let(:invalid_attributes) { { category_id: "     ", value: "test" } }

  let(:user)               { User.create(email: "sample@example.com") }
  let(:category)           { user.categories.create(title: "House Rent", type: "Expense") }
  let(:monthly_budget)     { user.monthly_budgets.build(month: Date.today.to_s) }
  let(:expected_cash_flow) { monthly_budget.expected_cash_flows.build(valid_attributes) }
  let(:actual_cash_flow)   { monthly_budget.actual_cash_flows.build(valid_attributes) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AssetsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    before do
      expected_cash_flow.save!
      actual_cash_flow.save!
    end

    it "returns a success response" do
      get :index, params: { user_id: user.to_param, monthly_budget_id: monthly_budget.to_param }, session: valid_session
      expect(response).to be_successful
    end

    it "returns non-success response" do
      get :index, params: { user_id: user.to_param, monthly_budget_id: 'test' }, session: valid_session
      expect(response).not_to be_successful

      response_body = JSON.parse(response.body)
      expect(response_body['message']).to eq 'Params: monthly_budget_id should be of format MMYYYY'
    end

    it "returns a JSON response with expected cash_flows" do
      get :index, params: { user_id: user.to_param, monthly_budget_id: monthly_budget.to_param, filter: 'expected' }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body['expected'].count).to eq 1
      cat_obj_id = BSON::ObjectId.from_string response_body['expected'][0]["category_id"]["$oid"]
      expect(cat_obj_id).to eq valid_attributes[:category_id]
      expect(response_body['expected'][0]["value"]).to eq valid_attributes[:value]
    end

    it "returns a JSON response with actual cash_flows" do
      get :index, params: { user_id: user.to_param, monthly_budget_id: monthly_budget.to_param, filter: 'actual' }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body['actual'].count).to eq 1

      cat_obj_id = BSON::ObjectId.from_string response_body['actual'][0]["category_id"]["$oid"]
      expect(cat_obj_id).to eq valid_attributes[:category_id]
      expect(response_body['actual'][0]["value"]).to eq valid_attributes[:value]
    end

    it "returns a JSON response with all cash_flows" do
      get :index, params: { user_id: user.to_param, monthly_budget_id: monthly_budget.to_param, filter: 'all' }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body['actual'].count).to eq 1
      expect(response_body['expected'].count).to eq 1
    end

    it "returns a JSON response with all cash_flows with empty filter params" do
      get :index, params: { user_id: user.to_param, monthly_budget_id: monthly_budget.to_param }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body['actual'].count).to eq 1
      expect(response_body['expected'].count).to eq 1
    end

    pending "returns a JSON response with all cash_flows grouped by category_id" do
      get :index, params: { user_id: user.to_param, monthly_budget_id: monthly_budget.to_param, filter: 'all_grouped_by_category' }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body.count).to eq 1
      expect(response_body[category.id]['expected'].value).to eq 1000
      expect(response_body[category.id]['actual'].value).to eq 1000
    end
  end

  describe "POST #create" do
    before { monthly_budget.save! }

    context "with valid params" do
      it "creates a new Expected CashFlow" do
        before_count = monthly_budget.expected_cash_flows.count
        post :create, params: { user_id: user.to_param, monthly_budget_id: monthly_budget.to_param, cash_flow: valid_attributes }, session: valid_session
        monthly_budget.reload
        after_count = monthly_budget.expected_cash_flows.count

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
        post :create, params: { user_id: user.to_param, monthly_budget_id: monthly_budget.to_param, cash_flow: { category_id: category.id, value: "test" } }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end
end
