require "rails_helper"

RSpec.describe CashFlowsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/users/3/monthly_budgets/2/cash_flows").to route_to("cash_flows#index", user_id: "3", monthly_budget_id: "2")
    end

    it "routes to #show" do
      expect(get: "/users/3/monthly_budgets/2/actual_cash_flows/1").to route_to("cash_flows#show", user_id: "3", monthly_budget_id: "2", id: "1")
    end

    it "routes to #create" do
      expect(post: "/users/3/monthly_budgets/2/expected_cash_flows").to route_to("cash_flows#create", user_id: "3", monthly_budget_id: "2")
    end

    it "routes to #update via PUT" do
      expect(put: "/users/3/monthly_budgets/2/expected_cash_flows/1").to route_to("cash_flows#update", user_id: "3", monthly_budget_id: "2", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/users/3/monthly_budgets/2/expected_cash_flows/1").to route_to("cash_flows#update", user_id: "3", monthly_budget_id: "2", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/users/3/monthly_budgets/2/expected_cash_flows/1").to route_to("cash_flows#destroy", user_id: "3", monthly_budget_id: "2", id: "1")
    end
  end
end
