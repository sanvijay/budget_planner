require "rails_helper"

RSpec.describe UserAccessesController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/users/1/user_access").to route_to("user_accesses#show", user_id: "1")
    end

    it "routes to #claim_plus_access via POST" do
      expect(post: "/users/2/claim_plus_access").to route_to("user_accesses#claim_plus_access", user_id: "2")
    end

    it "routes to #refer via POST" do
      expect(post: "/users/2/refer").to route_to("user_accesses#refer", user_id: "2")
    end
  end
end
