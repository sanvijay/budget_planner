require 'rails_helper'

RSpec.describe BenefitsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Benefit. As you add validations to Benefit, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes)   { { title: "House", value: 1000 } }
  let(:invalid_attributes) { { title: "     ", value: "test" } }

  let(:user)    { User.new(email: "sample@example.com") }
  let(:benefit) { user.benefits.build(valid_attributes) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BenefitsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    before { benefit.save! }

    it "returns a success response" do
      get :index, params: { user_id: user.to_param }, session: valid_session
      expect(response).to be_successful
    end

    it "returns a JSON response with benefits" do
      get :index, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body.count).to eq 1
      expect(response_body[0]["title"]).to eq valid_attributes[:title]
      expect(response_body[0]["value"]).to eq valid_attributes[:value]
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      benefit.save!
      get :show, params: { user_id: user.to_param, id: benefit.to_param }, session: valid_session
      expect(response).to be_successful

      response_body = JSON.parse(response.body)
      expect(response_body["title"]).to eq valid_attributes[:title]
      expect(response_body["value"]).to eq valid_attributes[:value]
    end
  end

  describe "POST #create" do
    before { user.save! }

    context "with valid params" do
      it "creates a new Benefit" do
        before_count = user.benefits.count
        post :create, params: { user_id: user.to_param, benefit: valid_attributes }, session: valid_session
        user.reload
        after_count = user.benefits.count

        expect(after_count - before_count).to eq 1
      end

      it "renders a JSON response with the new benefit" do
        post :create, params: { user_id: user.to_param, benefit: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new benefit" do
        post :create, params: { user_id: user.to_param, benefit: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "PUT #update" do
    before { benefit.save! }

    context "with valid params" do
      let(:new_attributes) do
        { title: "Factory", value: 2000 }
      end

      it "updates the requested benefit" do
        put :update, params: { user_id: user.to_param, id: benefit.to_param, benefit: new_attributes }, session: valid_session
        benefit.reload
        expect(benefit.title).to eq new_attributes[:title]
        expect(benefit.value).to eq new_attributes[:value]
      end

      it "renders a JSON response with the benefit" do
        put :update, params: { user_id: user.to_param, id: benefit.to_param, benefit: new_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the benefit" do
        put :update, params: { user_id: user.to_param, id: benefit.to_param, benefit: invalid_attributes }, session: valid_session
        benefit.reload
        expect(response).to have_http_status(:unprocessable_entity)
        expect(benefit.title).to eq valid_attributes[:title]
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested benefit" do
      benefit.save!
      before_count = user.benefits.count
      delete :destroy, params: { user_id: user.to_param, id: benefit.to_param }, session: valid_session
      user.reload
      after_count = user.benefits.count

      expect(after_count - before_count).to eq(-1)
    end
  end
end
