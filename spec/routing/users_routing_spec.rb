require "rails_helper"

RSpec.describe UsersController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/users/1").to route_to("users#show", user_id: "1")
    end

    it "routes to #create" do
      expect(post: "/users").to route_to("users#create")
    end

    it "routes to #destroy" do
      expect(delete: "/users/1").to route_to("users#destroy", user_id: "1")
    end
  end
end
