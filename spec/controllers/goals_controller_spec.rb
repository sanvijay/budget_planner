require 'rails_helper'

RSpec.describe GoalsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # goal. As you add validations to goal, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      description: "Bike",
      target: 1000,
      start_date: Date.today,
      end_date: Date.today + 1,
      score_weightage_out_of_100: 10
    }
  end

  let(:invalid_attributes) do
    {
      description: "   ",
      target: 'test',
      start_date: Date.today,
      end_date: Date.today
    }
  end

  let(:user) { User.create(email: "sample@example.com", password: "Qweasd12!") }
  let(:goal) { user.goals.build(valid_attributes) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # GoalsController. Be sure to keep this updated too.
  let(:valid_session) {}

  describe "GET #index" do
    before { goal.save! }

    it "returns a success response" do
      get :index, params: { user_id: user.to_param }, session: valid_session
      expect(response).to be_successful
    end

    it "returns a JSON response with goals" do
      get :index, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body.count).to eq 1

      slice_keys = %w[description target start_date end_date planned score_weightage_out_of_100]
      validate_attr = response_body[0].slice(*slice_keys)
      expect(validate_attr).to eq(
        "description" => "Bike",
        "end_date" => (Date.today + 1).to_s,
        "start_date" => Date.today.to_s,
        "target" => 1000.0,
        "planned" => 1000.0,
        "score_weightage_out_of_100" => 10
      )
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      goal.save!
      get :show, params: { user_id: user.to_param, id: goal.to_param }, session: valid_session
      expect(response).to be_successful

      response_body = JSON.parse(response.body)
      slice_keys = %w[description target start_date end_date score_weightage_out_of_100]
      validate_attr = response_body.slice(*slice_keys)
      expect(validate_attr).to eq(
        "description" => "Bike",
        "end_date" => (Date.today + 1).to_s,
        "start_date" => Date.today.to_s,
        "target" => 1000.0,
        "score_weightage_out_of_100" => 10
      )
    end
  end

  describe "POST #create" do
    before { user.save! }

    context "with valid params" do
      it "creates a new goal" do
        before_count = user.goals.count
        post :create, params: { user_id: user.to_param, goal: valid_attributes }, session: valid_session
        user.reload
        after_count = user.goals.count

        expect(after_count - before_count).to eq 1
      end

      it "returns the goal hash" do
        post :create, params: { user_id: user.to_param, goal: valid_attributes }, session: valid_session

        response_body = JSON.parse(response.body)
        slice_keys = %w[description target start_date end_date planned score_weightage_out_of_100]
        validate_attr = response_body.slice(*slice_keys)
        expect(validate_attr).to eq(
          "description" => "Bike",
          "end_date" => (Date.today + 1).to_s,
          "start_date" => Date.today.to_s,
          "target" => 1000.0,
          "planned" => 1000.0,
          "score_weightage_out_of_100" => 10
        )
      end

      it "renders a JSON response with the new goal" do
        post :create, params: { user_id: user.to_param, goal: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new goal" do
        post :create, params: { user_id: user.to_param, goal: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "PUT #update" do
    before { goal.save! }

    context "with valid params" do
      let(:new_attributes) do
        { description: "Super Bike", target: 2000 }
      end

      it "updates the requested goal" do
        put :update, params: { user_id: user.to_param, id: goal.to_param, goal: new_attributes }, session: valid_session
        goal.reload
        expect(goal.description).to eq new_attributes[:description]
        expect(goal.target).to eq new_attributes[:target]
      end

      it "updates the requested goal target alone" do
        put :update, params: { user_id: user.to_param, id: goal.to_param, goal: { target: 2000 } }, session: valid_session
        goal.reload
        expect(goal.target).to eq 2000
      end

      it "renders a JSON response with the goal" do
        put :update, params: { user_id: user.to_param, id: goal.to_param, goal: new_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the goal" do
        put :update, params: { user_id: user.to_param, id: goal.to_param, goal: invalid_attributes }, session: valid_session
        goal.reload
        expect(response).to have_http_status(:unprocessable_entity)
        expect(goal.description).to eq valid_attributes[:description]
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested goal" do
      goal.save!
      before_count = user.goals.count
      delete :destroy, params: { user_id: user.to_param, id: goal.to_param }, session: valid_session
      user.reload
      after_count = user.goals.count

      expect(after_count - before_count).to eq(-1)
    end
  end
end
