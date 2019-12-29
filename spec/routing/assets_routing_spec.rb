require "rails_helper"

RSpec.describe AssetsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/users/2/assets").to route_to("assets#index", user_id: "2")
    end

    it "routes to #show" do
      expect(get: "/users/2/assets/1").to route_to("assets#show", user_id: "2", id: "1")
    end

    it "routes to #create" do
      expect(post: "/users/2/assets").to route_to("assets#create", user_id: "2")
    end

    it "routes to #update via PUT" do
      expect(put: "/users/2/assets/1").to route_to("assets#update", id: "1", user_id: "2")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/users/2/assets/1").to route_to("assets#update", id: "1", user_id: "2")
    end

    it "routes to #destroy" do
      expect(delete: "/users/2/assets/1").to route_to("assets#destroy", id: "1", user_id: "2")
    end
  end
end
