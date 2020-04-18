require 'rails_helper'

RSpec.describe CustomRulesController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # custom_rule. As you add validations to custom_rule, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      emergency_corpus: nil,
      emergency_corpus_score_weightage_out_of_100: 100,
      outflow_split_percentage: { emi: 30, expense: 40, equity_investment: 10, debt_investment: 20 },
      outflow_split_score_weightage_out_of_100: 100
    }
  end

  let(:invalid_attributes) do
    {
      outflow_split_score_weightage_out_of_100: nil
    }
  end

  let(:valid_user_profile_attr) do
    {
      first_name: "Bike",
      last_name: "Racer",
      dob: Time.zone.today - 1.day,
      gender: "Male"
    }
  end

  let(:user)         { User.create(email: "sample@example.com") }
  let(:user_profile) { user.build_user_profile(valid_user_profile_attr) }
  let(:custom_rule)  { user.build_custom_rule(valid_attributes) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { user_id: user.to_param }, session: valid_session
      expect(response).to be_successful
    end

    it "returns a JSON response with custom_rule" do
      user_profile.save!
      custom_rule.save!
      get :show, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)

      slice_keys = %w[emergency_corpus emergency_corpus_score_weightage_out_of_100 outflow_split_percentage outflow_split_score_weightage_out_of_100]
      validate_attr = response_body.slice(*slice_keys)
      valid_attributes[:emergency_corpus] = 0.0
      valid_attributes[:outflow_split_percentage] = { "debt_investment" => 20, "emi" => 30, "equity_investment" => 10, "expense" => 40 }

      expect(validate_attr).to eq(valid_attributes.stringify_keys)
    end

    it "returns nil JSON response for no custom_rule" do
      get :show, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)
      slice_keys = %w[emergency_corpus emergency_corpus_score_weightage_out_of_100 outflow_split_percentage outflow_split_score_weightage_out_of_100]
      validate_attr = response_body.slice(*slice_keys)
      expect(validate_attr).to eq(
        "emergency_corpus" => nil,
        "emergency_corpus_score_weightage_out_of_100" => 100,
        "outflow_split_percentage" => nil,
        "outflow_split_score_weightage_out_of_100" => 100
      )
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      before { user_profile.save!; custom_rule.save! } # rubocop:disable Style/Semicolon

      let(:new_attributes) do
        { outflow_split_score_weightage_out_of_100: 50 }
      end

      it "updates the requested custom_rule" do
        put :update, params: { user_id: user.to_param, custom_rule: new_attributes }, session: valid_session
        custom_rule.reload
        expect(custom_rule.outflow_split_score_weightage_out_of_100).to eq new_attributes[:outflow_split_score_weightage_out_of_100]
      end

      it "renders a JSON response with the custom_rule" do
        put :update, params: { user_id: user.to_param, custom_rule: new_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the custom_rule" do
        user_profile.save!
        put :update, params: { user_id: user.to_param, custom_rule: invalid_attributes }, session: valid_session
        custom_rule = user.custom_rule

        expect(response).to have_http_status(:unprocessable_entity)
        expect(custom_rule.outflow_split_score_weightage_out_of_100).to eq valid_attributes[:outflow_split_score_weightage_out_of_100]
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      it "renders a JSON response with errors for the custom_rule for user_profile not saved" do
        put :update, params: { user_id: user.to_param, custom_rule: valid_attributes }, session: valid_session

        expect(response).to have_http_status(:unprocessable_entity)
        expect(custom_rule.outflow_split_score_weightage_out_of_100).to eq valid_attributes[:outflow_split_score_weightage_out_of_100]
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end
end
