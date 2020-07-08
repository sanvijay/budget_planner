require "rails_helper"

RSpec.describe AssetsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/users/2/monthly_budgets/1/actual_cash_flow_logs").to route_to("actual_cash_flow_logs#index", user_id: "2", monthly_budget_id: "1")
    end

    it "routes to #index_batch" do
      expect(get: "/users/2/monthly_budgets/index_actual_cash_flow_logs_batch").to route_to("actual_cash_flow_logs#index_batch", user_id: "2")
    end

    it "routes to #create" do
      expect(post: "/users/2/monthly_budgets/1/actual_cash_flow_logs").to route_to("actual_cash_flow_logs#create", user_id: "2", monthly_budget_id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/users/2/monthly_budgets/1/actual_cash_flow_logs/3").to route_to("actual_cash_flow_logs#destroy", user_id: "2", monthly_budget_id: "1", id: "3")
    end
  end
end
