require 'rails_helper'

RSpec.describe "Customers", type: :request do
  describe "POST customers/:id/claim-reward" do
    ### Grant reward to customer and test claiming it ####
    context "testing error scenarios" do
      it "should throw 400 for insufficient params" do
        post "/api/v1/customers/random/claim-reward", headers: api_request_headers
        expect(response).to have_http_status(400)
        expect(response.parsed_body['description']).to eql("param is missing or the value is empty: quantity")
      end

      it "should throw 404 for invalid customer id" do
        post "/api/v1/customers/random/claim-reward", params: {
          quantity: 1, customer_reward_id: "random"
        }, headers: api_request_headers
        expect(response).to have_http_status(404)
        expect(response.parsed_body['description']).to eql('Customer not found')
      end

      it "should throw 404 for invalid customer_reward_id" do
        customer = FactoryBot.create(:customer)
        post "/api/v1/customers/#{customer.gid}/claim-reward", params: {
          quantity: 1, customer_reward_id: "random"
        }, headers: api_request_headers
        expect(response).to have_http_status(404)
        expect(response.parsed_body['description']).to eql('Customer Reward not found')
      end
    end
  end
end
