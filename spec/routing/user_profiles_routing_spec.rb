require "rails_helper"

RSpec.describe UserProfilesController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/users/1/user_profile").to route_to("user_profiles#show", user_id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/users/2/user_profile").to route_to("user_profiles#update", user_id: "2")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/users/2/user_profile").to route_to("user_profiles#update", user_id: "2")
    end
  end
end
