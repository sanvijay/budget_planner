require "rails_helper"

RSpec.describe CategoriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/users/2/categories").to route_to("categories#index", user_id: "2")
    end

    it "routes to #show" do
      expect(get: "/users/2/categories/1").to route_to("categories#show", user_id: "2", id: "1")
    end

    it "routes to #create" do
      expect(post: "/users/2/categories").to route_to("categories#create", user_id: "2")
    end

    it "routes to #update via PUT" do
      expect(put: "/users/2/categories/1").to route_to("categories#update", user_id: "2", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/users/2/categories/1").to route_to("categories#update", user_id: "2", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/users/2/categories/1").to route_to("categories#destroy", user_id: "2", id: "1")
    end
  end
end
