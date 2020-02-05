require "rails_helper"

RSpec.describe CashFlowsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/users/3/monthly_budgets/2/cash_flows").to route_to("cash_flows#index", user_id: "3", monthly_budget_id: "2")
    end

    it "routes to #create" do
      expect(post: "/users/3/monthly_budgets/2/cash_flows").to route_to("cash_flows#create", user_id: "3", monthly_budget_id: "2")
    end
  end
end
