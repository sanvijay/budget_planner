require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # account. As you add validations to account, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes)   { { name: "Food Card" } }
  let(:invalid_attributes) { { name: "         " } }

  let(:user)    { User.new(email: "sample@example.com", password: "Qweasd12!") }
  let(:account) { user.accounts.build(valid_attributes) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # accountsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    before { account.save! }

    it "returns a success response" do
      get :index, params: { user_id: user.to_param }, session: valid_session
      expect(response).to be_successful
    end

    it "returns a JSON response with accounts" do
      get :index, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body.count).to eq 1
      expect(response_body[0]["name"]).to eq valid_attributes[:name]
    end
  end

  describe "POST #create" do
    before { user.save! }

    context "with valid params" do
      it "creates a new account" do
        before_count = user.accounts.count
        post :create, params: { user_id: user.to_param, account: valid_attributes }, session: valid_session
        user.reload
        after_count = user.accounts.count

        expect(after_count - before_count).to eq 1
      end

      it "renders a JSON response with the new account" do
        post :create, params: { user_id: user.to_param, account: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new account" do
        post :create, params: { user_id: user.to_param, account: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "PUT #update" do
    before { account.save! }

    context "with valid params" do
      let(:new_attributes) do
        { name: "New account" }
      end

      it "updates the requested account" do
        put :update, params: { user_id: user.to_param, id: account.to_param, account: new_attributes }, session: valid_session
        account.reload
        expect(account.name).to eq new_attributes[:name]
      end

      it "renders a JSON response with the account" do
        put :update, params: { user_id: user.to_param, id: account.to_param, account: new_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the account" do
        put :update, params: { user_id: user.to_param, id: account.to_param, account: invalid_attributes }, session: valid_session
        account.reload
        expect(response).to have_http_status(:unprocessable_entity)
        expect(account.name).to eq valid_attributes[:name]
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end
end
