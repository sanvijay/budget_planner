require 'rails_helper'

RSpec.describe QuizsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Quiz. As you add validations to Quiz, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes)   { { name: "Example", planned_before: true, score: 50 } }
  let(:invalid_attributes) { { name: "       ", planned_before: "tt", score: 50 } }

  let(:user) { User.create(email: "sample@example.com", password: "Qweasd12!") }
  let(:quiz) { Quiz.new(valid_attributes) }
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # QuizsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Quiz" do
        expect do
          post :create, params: { quiz: valid_attributes }, session: valid_session
        end.to change(Quiz, :count).by(1)
      end

      it "renders a JSON response with the new quiz" do
        post :create, params: { quiz: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new quiz" do
        post :create, params: { quiz: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "PUT #update" do
    before { quiz.save! }

    context "with valid params" do
      let(:new_attributes) do
        { name: "Super Bike" }
      end

      it "updates the requested quiz" do
        put :update, params: { user_id: user.to_param, id: quiz.to_param, quiz: new_attributes }, session: valid_session
        quiz.reload
        expect(quiz.name).to eq new_attributes[:name]
      end

      it "renders a JSON response with the quiz" do
        put :update, params: { user_id: user.to_param, id: quiz.to_param, quiz: new_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the quiz" do
        put :update, params: { user_id: user.to_param, id: quiz.to_param, quiz: invalid_attributes }, session: valid_session
        quiz.reload
        expect(response).to have_http_status(:unprocessable_entity)
        expect(quiz.name).to eq valid_attributes[:name]
      end
    end
  end
end
