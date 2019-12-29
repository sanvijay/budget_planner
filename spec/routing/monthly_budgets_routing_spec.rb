require "rails_helper"

RSpec.describe MonthlyBudgetsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/users/2/monthly_budgets").to route_to("monthly_budgets#index", user_id: "2")
    end

    it "routes to #show" do
      expect(get: "/users/2/monthly_budgets/1").to route_to("monthly_budgets#show", user_id: "2", id: "1")
    end

    it "routes to #create" do
      expect(post: "/users/2/monthly_budgets").to route_to("monthly_budgets#create", user_id: "2")
    end
  end
end
