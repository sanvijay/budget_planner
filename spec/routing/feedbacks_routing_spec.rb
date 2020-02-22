require "rails_helper"

RSpec.describe FeedbacksController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/feedbacks").to route_to("feedbacks#create")
    end
  end
end
