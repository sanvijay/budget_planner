require 'rails_helper'

RSpec.describe MonthlyBudgetsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # monthly_budget. As you add validations to monthly_budget, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { month: Date.today } }

  let(:invalid_attributes) { { month: "" } }

  let(:user) { User.create(email: "sample@example.com") }
  let(:monthly_budget) { user.monthly_budgets.build(valid_attributes) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # GoalsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    before { monthly_budget.save! }

    it "returns a success response" do
      get :index, params: { user_id: user.to_param }, session: valid_session
      expect(response).to be_successful
    end

    it "returns a JSON response with goals" do
      get :index, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body.count).to eq 1

      slice_keys = %w[month]
      validate_attr = response_body[0].slice(*slice_keys)
      expect(validate_attr).to eq("month" => "2019-12-29")
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      monthly_budget.save!
      get :show, params: { user_id: user.to_param, id: monthly_budget.to_param }, session: valid_session
      expect(response).to be_successful

      response_body = JSON.parse(response.body)
      slice_keys = %w[month]
      validate_attr = response_body.slice(*slice_keys)
      expect(validate_attr).to eq("month" => "2019-12-29")
    end
  end

  describe "POST #create" do
    before { user.save! }

    context "with valid params" do
      it "creates a new monthly_budget" do
        before_count = user.monthly_budgets.count
        post :create, params: { user_id: user.to_param, monthly_budget: valid_attributes }, session: valid_session
        user.reload
        after_count = user.monthly_budgets.count

        expect(after_count - before_count).to eq 1
      end

      it "renders a JSON response with the new monthly_budget" do
        post :create, params: { user_id: user.to_param, monthly_budget: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new monthly_budget" do
        post :create, params: { user_id: user.to_param, monthly_budget: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end
end
