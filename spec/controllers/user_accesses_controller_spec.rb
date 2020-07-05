require 'rails_helper'

RSpec.describe UserAccessesController, type: :controller do
  let(:user) { User.create(email: "sample@example.com", password: "Qweasd12!") }

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
      get :show, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)

      %w[referring_token plan].each do |key|
        expect(response_body[key]).not_to be_nil
      end

      expect(response_body["referred_users"]).to be_zero
      expect(response_body["referred_by"]).to be_nil
    end
  end

  describe "POST #refer" do
    it "returns failure if already refered by someone else" do
      new_user = User.create(email: "sample1@example.com", password: "Qweasd12!")
      user.user_access.referred_by = new_user.to_param
      user.save!

      post :refer, params: { user_id: user.to_param, referral_id: new_user.referring_token }, session: valid_session

      expect(response).to have_http_status(:bad_request)
      response_body = JSON.parse(response.body)
      expect(response_body['message']).to eq ['cannot be referred by multiple people']
    end

    it "returns a failure response if no referral code is found" do
      post :refer, params: { user_id: user.to_param, referral_id: "test" }, session: valid_session

      expect(response).to have_http_status(:bad_request)
      response_body = JSON.parse(response.body)
      expect(response_body['message']).to eq ['Invalid referral code']
    end

    it "returns a failure response if referral code is of same user" do
      post :refer, params: { user_id: user.to_param, referral_id: user.referring_token }, session: valid_session

      expect(response).to have_http_status(:bad_request)
      response_body = JSON.parse(response.body)
      expect(response_body['message']).to eq ['Invalid referral code']
    end

    it "returns a failure response if try to do mutual referral" do
      new_user = User.create(email: "sample1@example.com", password: "Qweasd12!")
      post :refer, params: { user_id: user.to_param, referral_id: new_user.referring_token }, session: valid_session
      expect(response).to have_http_status(:accepted)

      post :refer, params: { user_id: new_user.to_param, referral_id: user.referring_token }, session: valid_session
      expect(response).to have_http_status(:bad_request)
      response_body = JSON.parse(response.body)
      expect(response_body['message']).to eq ['Invalid referral code']
    end
  end
end
