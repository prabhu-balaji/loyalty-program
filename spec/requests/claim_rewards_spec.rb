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
        }, headers: api_request_headers, as: :json
        expect(response).to have_http_status(404)
        expect(response.parsed_body['description']).to eql('Customer not found')
      end

      it "should throw 404 for invalid customer_reward_id" do
        customer = FactoryBot.create(:customer)
        post "/api/v1/customers/#{customer.gid}/claim-reward", params: {
          quantity: 1, customer_reward_id: "random"
        }, headers: api_request_headers, as: :json
        expect(response).to have_http_status(404)
        expect(response.parsed_body['description']).to eql('CustomerReward not found')
      end

      it "should throw 400 for when customer_reward has expired" do
        customer = FactoryBot.create(:customer)
        customer_reward = customer.grant_reward(reward_id: coffee_reward.id, quantity: 1,
                                                expires_at: DateTime.current.utc - 1.day)
        post "/api/v1/customers/#{customer.gid}/claim-reward", params: {
          quantity: 1, customer_reward_id: customer_reward.gid
        }, headers: api_request_headers, as: :json
        expect(response).to have_http_status(400)
        expect(response.parsed_body['description']).to eql('Reward has expired.')
      end

      it "should throw 400 for when customer_reward has insufficient quantity" do
        customer = FactoryBot.create(:customer)
        customer_reward = customer.grant_reward(reward_id: coffee_reward.id, quantity: 1,
                                                expires_at: DateTime.current.utc + 1.day)
        post "/api/v1/customers/#{customer.gid}/claim-reward", params: {
          quantity: 2, customer_reward_id: customer_reward.gid
        }, headers: api_request_headers, as: :json
        expect(response).to have_http_status(400)
        expect(response.parsed_body['description']).to eql('Insufficient quantity')
      end
    end

    context "testing success scenarios" do
      it "should return success for reward claim" do
        customer = FactoryBot.create(:customer)
        customer_reward = customer.grant_reward(reward_id: coffee_reward.id, quantity: 1,
                                                expires_at: DateTime.current.utc + 1.day)
        post "/api/v1/customers/#{customer.gid}/claim-reward", params: {
          quantity: 1, customer_reward_id: customer_reward.gid
        }, headers: api_request_headers, as: :json
        expect(response).to have_http_status(200)
        expect(response.parsed_body['success']).to eql(true)

        ## Verifying db ##
        customer_reward.reload
        expect(customer_reward.quantity).to eql(0)

        post "/api/v1/customers/#{customer.gid}/claim-reward", params: {
          quantity: 1, customer_reward_id: customer_reward.gid
        }, headers: api_request_headers, as: :json
        expect(response).to have_http_status(400)
        expect(response.parsed_body['description']).to eql('Insufficient quantity')
      end

      it "should return success for reward claim for various quantities" do
        customer = FactoryBot.create(:customer)
        customer_reward = customer.grant_reward(reward_id: coffee_reward.id, quantity: 4, reward_program_id: coffee_reward_program[:id],
                                                expires_at: DateTime.current.utc + 1.day)
        post "/api/v1/customers/#{customer.gid}/claim-reward", params: {
          quantity: 1, customer_reward_id: customer_reward.gid
        }, headers: api_request_headers, as: :json
        expect(response).to have_http_status(200)
        expect(response.parsed_body['success']).to eql(true)

        ## Verifying db ##
        customer_reward.reload
        expect(customer_reward.quantity).to eql(3)
        redeemed_customer_rewards = customer_reward.redeemed_customer_rewards
        expect(redeemed_customer_rewards.size).to eql(1)
        redeemed_customer_reward = redeemed_customer_rewards.first
        expect(redeemed_customer_reward.reward_id).to eql(coffee_reward.id)
        expect(redeemed_customer_reward.reward_program_id).to eql(coffee_reward_program[:id])
        expect(redeemed_customer_reward.quantity).to eql(1)
        expect(redeemed_customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:redeemed])

        post "/api/v1/customers/#{customer.gid}/claim-reward", params: {
          quantity: 3, customer_reward_id: customer_reward.gid
        }, headers: api_request_headers, as: :json
        expect(response).to have_http_status(200)

        ## Verifying db ##
        customer_reward.reload
        expect(customer_reward.quantity).to eql(0)
        redeemed_customer_rewards = customer_reward.redeemed_customer_rewards
        expect(redeemed_customer_rewards.size).to eql(2)
        redeemed_customer_reward = redeemed_customer_rewards.last
        expect(redeemed_customer_reward.reward_id).to eql(coffee_reward.id)
        expect(redeemed_customer_reward.reward_program_id).to eql(coffee_reward_program[:id])
        expect(redeemed_customer_reward.quantity).to eql(3)
        expect(redeemed_customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:redeemed])
      end
    end
  end
end
