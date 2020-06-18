require 'rails_helper'

RSpec.describe LoansController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # loan. As you add validations to loan, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      description: "Bike",
      value: 1000,
      emi: 10,
      start_date: Time.zone.today,
      end_date: Time.zone.today + 1
    }
  end

  let(:invalid_attributes) do
    {
      description: "   ",
      value: 'test',
      start_date: Time.zone.today,
      end_date: Time.zone.today
    }
  end

  let(:user) { User.create(email: "sample@example.com", password: "Qweasd12!") }
  let(:loan) { user.loans.build(valid_attributes) }
  let(:user_profile) { user.build_user_profile(first_name: "Bike", last_name: "Racer", dob: Date.new(1990, 3, 28), gender: "Male") }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # LoansController. Be sure to keep this updated too.
  let(:valid_session) {}

  before { user_profile.save! }

  describe "GET #index" do
    before { loan.save! }

    it "returns a success response" do
      get :index, params: { user_id: user.to_param }, session: valid_session
      expect(response).to be_successful
    end

    it "returns a JSON response with loans" do
      get :index, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body.count).to eq 1

      slice_keys = %w[description value start_date end_date planned]
      validate_attr = response_body[0].slice(*slice_keys)
      expect(validate_attr).to eq(
        "description" => "Bike",
        "end_date" => (Time.zone.today + 1).to_s,
        "start_date" => Time.zone.today.to_s,
        "value" => 1000.0,
        "planned" => 10.0
      )
    end
  end

  describe "POST #create" do
    before { user.save! }

    context "with valid params" do
      it "creates a new loan" do
        before_count = user.loans.count
        post :create, params: { user_id: user.to_param, loan: valid_attributes }, session: valid_session
        user.reload
        after_count = user.loans.count

        expect(after_count - before_count).to eq 1
      end

      it "returns the loan hash" do
        post :create, params: { user_id: user.to_param, loan: valid_attributes }, session: valid_session

        response_body = JSON.parse(response.body)
        slice_keys = %w[description value start_date end_date planned]
        validate_attr = response_body.slice(*slice_keys)
        expect(validate_attr).to eq(
          "description" => "Bike",
          "end_date" => (Time.zone.today + 1).to_s,
          "start_date" => Time.zone.today.to_s,
          "value" => 1000.0,
          "planned" => 10.0
        )
      end

      it "renders a JSON response with the new loan" do
        post :create, params: { user_id: user.to_param, loan: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new loan" do
        post :create, params: { user_id: user.to_param, loan: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "PUT #update" do
    before { loan.save! }

    context "with valid params" do
      let(:new_attributes) do
        { description: "Super Bike", value: 2000 }
      end

      it "updates the requested loan" do
        put :update, params: { user_id: user.to_param, id: loan.to_param, loan: new_attributes }, session: valid_session
        loan.reload
        expect(loan.description).to eq new_attributes[:description]
        expect(loan.value).to eq new_attributes[:value]
      end

      it "updates the requested loan value alone" do
        put :update, params: { user_id: user.to_param, id: loan.to_param, loan: { value: 2000 } }, session: valid_session
        loan.reload
        expect(loan.value).to eq 2000
      end

      it "renders a JSON response with the loan" do
        put :update, params: { user_id: user.to_param, id: loan.to_param, loan: new_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the loan" do
        put :update, params: { user_id: user.to_param, id: loan.to_param, loan: invalid_attributes }, session: valid_session
        loan.reload
        expect(response).to have_http_status(:unprocessable_entity)
        expect(loan.description).to eq valid_attributes[:description]
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end
end
