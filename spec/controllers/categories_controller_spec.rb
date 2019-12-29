require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Category. As you add validations to Category, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes)   { { title: "House Rent", type: "Expense" } }
  let(:invalid_attributes) { { title: "          ", type: "       " } }

  let(:user)     { User.new(email: "sample@example.com") }
  let(:category) { user.categories.build(valid_attributes) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CategoriesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    before { category.save! }

    it "returns a success response" do
      get :index, params: { user_id: user.to_param }, session: valid_session
      expect(response).to be_successful
    end

    it "returns a JSON response with categories" do
      get :index, params: { user_id: user.to_param }, session: valid_session

      response_body = JSON.parse(response.body)
      expect(response_body.count).to eq 1
      expect(response_body[0]["title"]).to eq valid_attributes[:title]
      expect(response_body[0]["type"]).to eq valid_attributes[:type]
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      category.save!
      get :show, params: { user_id: user.to_param, id: category.to_param }, session: valid_session
      expect(response).to be_successful

      response_body = JSON.parse(response.body)
      expect(response_body["title"]).to eq valid_attributes[:title]
      expect(response_body["type"]).to eq valid_attributes[:type]
    end
  end

  describe "POST #create" do
    before { user.save! }

    context "with valid params" do
      it "creates a new category" do
        before_count = user.categories.count
        post :create, params: { user_id: user.to_param, category: valid_attributes }, session: valid_session
        user.reload
        after_count = user.categories.count

        expect(after_count - before_count).to eq 1
      end

      it "renders a JSON response with the new category" do
        post :create, params: { user_id: user.to_param, category: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new category" do
        post :create, params: { user_id: user.to_param, category: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "PUT #update" do
    before { category.save! }

    context "with valid params" do
      let(:new_attributes) do
        { title: "Factory", type: 'Expense' }
      end

      it "updates the requested category" do
        put :update, params: { user_id: user.to_param, id: category.to_param, category: new_attributes }, session: valid_session
        category.reload
        expect(category.title).to eq new_attributes[:title]
        expect(category.type).to eq new_attributes[:type]
      end

      it "renders a JSON response with the category" do
        put :update, params: { user_id: user.to_param, id: category.to_param, category: new_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the category" do
        put :update, params: { user_id: user.to_param, id: category.to_param, category: invalid_attributes }, session: valid_session
        category.reload
        expect(response).to have_http_status(:unprocessable_entity)
        expect(category.title).to eq valid_attributes[:title]
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested category" do
      category.save!
      before_count = user.categories.count
      delete :destroy, params: { user_id: user.to_param, id: category.to_param }, session: valid_session
      user.reload
      after_count = user.categories.count

      expect(after_count - before_count).to eq(-1)
    end
  end
end
