require 'rails_helper'

RSpec.describe UserProfilesController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # user_profile. As you add validations to user_profile, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      first_name: "Bike",
      last_name: "Racer",
      dob: Date.today - 1.days,
      gender: "Male",
      monthly_income: nil
    }
  end

  let(:invalid_attributes) do
    {
      first_name: "  ",
      last_name: "  ",
      dob: Date.today + 1.days,
      gender: 123
    }
  end

  let(:user)         { User.create(email: "sample@example.com") }
  let(:user_profile) { user.build_user_profile(valid_attributes) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { user_id: user.to_param }, session: valid_session
      expect(response).to be_successful
    end

    it "returns a JSON response with user_profile" do
      user_profile.save!
      get :show, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)

      slice_keys = %w[first_name last_name dob gender monthly_income]
      validate_attr = response_body.slice(*slice_keys)
      validate_attr["dob"] = Date.parse(validate_attr["dob"])

      expect(validate_attr).to eq(valid_attributes.stringify_keys)
    end

    it "returns nil JSON response for no user_profile" do
      get :show, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)
      slice_keys = %w[first_name last_name dob gender monthly_income]
      validate_attr = response_body.slice(*slice_keys)
      expect(validate_attr).to eq(
        "dob" => nil,
        "first_name" => nil,
        "gender" => nil,
        "last_name" => nil,
        "monthly_income" => nil
      )
    end
  end

  describe "PUT #update" do
    before { user_profile.save! }

    context "with valid params" do
      let(:new_attributes) do
        { first_name: "Super", last_name: "Bike" }
      end

      it "updates the requested user_profile" do
        put :update, params: { user_id: user.to_param, user_profile: new_attributes }, session: valid_session
        user_profile.reload
        expect(user_profile.first_name).to eq new_attributes[:first_name]
        expect(user_profile.last_name).to eq new_attributes[:last_name]
      end

      it "renders a JSON response with the user_profile" do
        put :update, params: { user_id: user.to_param, user_profile: new_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the user_profile" do
        put :update, params: { user_id: user.to_param, id: user_profile.to_param, user_profile: invalid_attributes }, session: valid_session
        user_profile.reload
        expect(response).to have_http_status(:unprocessable_entity)
        expect(user_profile.first_name).to eq valid_attributes[:first_name]
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end
end
