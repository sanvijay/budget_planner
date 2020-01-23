require "rails_helper"

RSpec.describe CustomRulesController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/users/1/custom_rule").to route_to("custom_rules#show", user_id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/users/2/custom_rule").to route_to("custom_rules#update", user_id: "2")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/users/2/custom_rule").to route_to("custom_rules#update", user_id: "2")
    end
  end
end
