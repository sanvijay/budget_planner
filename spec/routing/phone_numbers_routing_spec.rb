require "rails_helper"

RSpec.describe PhoneNumbersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/users/2/phone_numbers").to route_to("phone_numbers#index", user_id: "2")
    end

    it "routes to #create" do
      expect(post: "/users/2/phone_numbers").to route_to("phone_numbers#create", user_id: "2")
    end

    it "routes to #verify" do
      expect(post: "/users/2/phone_numbers/verify").to route_to("phone_numbers#verify", user_id: "2")
    end
  end
end
