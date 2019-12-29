require "rails_helper"

RSpec.describe GoalsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/users/2/goals").to route_to("goals#index", user_id: "2")
    end

    it "routes to #show" do
      expect(get: "/users/2/goals/1").to route_to("goals#show", user_id: "2", id: "1")
    end

    it "routes to #create" do
      expect(post: "/users/2/goals").to route_to("goals#create", user_id: "2")
    end

    it "routes to #update via PUT" do
      expect(put: "/users/2/goals/1").to route_to("goals#update", user_id: "2", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/users/2/goals/1").to route_to("goals#update", user_id: "2", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/users/2/goals/1").to route_to("goals#destroy", user_id: "2", id: "1")
    end
  end
end
