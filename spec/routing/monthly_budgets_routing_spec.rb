require "rails_helper"

RSpec.describe MonthlyBudgetsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/users/2/monthly_budgets").to route_to("monthly_budgets#index", user_id: "2")
    end

    it "routes to #update via PUT" do
      expect(put: "/users/2/monthly_budgets/1").to route_to("monthly_budgets#update", id: "1", user_id: "2")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/users/2/monthly_budgets/1").to route_to("monthly_budgets#update", id: "1", user_id: "2")
    end
  end
end
