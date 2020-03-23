require "rails_helper"

RSpec.describe PersonalAdvisorRequestsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/personal_advisor_requests").to route_to("personal_advisor_requests#create")
    end
  end
end
