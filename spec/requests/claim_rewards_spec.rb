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
                                                expires_at: DateTime.current.utc)
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

  describe "Test available customer rewards API: GET customers/:id/customer-rewards" do
    it 'should throw error when customer not present' do
      get "/api/v1/customers/random/customer-rewards", headers: api_request_headers
      expect(response).to have_http_status(404)
      expect(response.parsed_body['description']).to eql('Customer not found')
    end

    it 'should return empty array for no rewards' do
      customer = FactoryBot.create(:customer)
      get "/api/v1/customers/#{customer.gid}/customer-rewards", headers: api_request_headers
      expect(response).to have_http_status(200)
      expect(response.parsed_body).to eql({ "customer_rewards" => [] })
    end

    it 'should return result for available rewards' do
      customer = FactoryBot.create(:customer)
      customer_reward_1 = customer.grant_reward(reward_id: coffee_reward.id, quantity: 2,
                                                expires_at: DateTime.current.utc)
      customer_reward_2 = customer.grant_reward(reward_id: coffee_reward.id, quantity: 4)
      get "/api/v1/customers/#{customer.gid}/customer-rewards", headers: api_request_headers
      expect(response).to have_http_status(200)
      response_json = response.parsed_body
      expect(response_json["customer_rewards"].size).to eql(2)

      expect(response_json["customer_rewards"][0]['id']).to eql(customer_reward_1.gid)
      expect(response_json["customer_rewards"][0]['quantity']).to eql(customer_reward_1.quantity)
      expect(response_json["customer_rewards"][0]['expires_at']).to eql(customer_reward_1.expires_at.to_time.iso8601)
      expect(response_json["customer_rewards"][0]['name']).to eql("Coffee")

      expect(response_json["customer_rewards"][1]['id']).to eql(customer_reward_2.gid)
      expect(response_json["customer_rewards"][1]['quantity']).to eql(customer_reward_2.quantity)
      expect(response_json["customer_rewards"][1]['expires_at']).to eql(nil)
      expect(response_json["customer_rewards"][1]['name']).to eql("Coffee")

      ## Lets claim customer_reward_2. Quantity 2 and then 2
      post "/api/v1/customers/#{customer.gid}/claim-reward", params: {
        quantity: 2, customer_reward_id: customer_reward_2.gid
      }, headers: api_request_headers, as: :json
      expect(response).to have_http_status(200)

      ###  Hitting available rewards API
      get "/api/v1/customers/#{customer.gid}/customer-rewards", headers: api_request_headers
      expect(response).to have_http_status(200)
      response_json = response.parsed_body
      expect(response_json["customer_rewards"].size).to eql(2)
      expect(response_json["customer_rewards"][0]['id']).to eql(customer_reward_1.gid)
      expect(response_json["customer_rewards"][0]['quantity']).to eql(customer_reward_1.quantity)
      expect(response_json["customer_rewards"][0]['expires_at']).to eql(customer_reward_1.expires_at.to_time.iso8601)
      expect(response_json["customer_rewards"][0]['name']).to eql("Coffee")

      expect(response_json["customer_rewards"][1]['id']).to eql(customer_reward_2.gid)
      expect(response_json["customer_rewards"][1]['quantity']).to eql(2)
      expect(response_json["customer_rewards"][1]['expires_at']).to eql(nil)
      expect(response_json["customer_rewards"][1]['name']).to eql("Coffee")

      post "/api/v1/customers/#{customer.gid}/claim-reward", params: {
        quantity: 2, customer_reward_id: customer_reward_2.gid
      }, headers: api_request_headers, as: :json
      expect(response).to have_http_status(200)

      ###  Hitting available rewards API
      get "/api/v1/customers/#{customer.gid}/customer-rewards", headers: api_request_headers
      expect(response).to have_http_status(200)
      response_json = response.parsed_body
      expect(response_json["customer_rewards"].size).to eql(1)
      expect(response_json["customer_rewards"][0]['id']).to eql(customer_reward_1.gid)
      expect(response_json["customer_rewards"][0]['quantity']).to eql(customer_reward_1.quantity)
      expect(response_json["customer_rewards"][0]['expires_at']).to eql(customer_reward_1.expires_at.to_time.iso8601)
      expect(response_json["customer_rewards"][0]['name']).to eql("Coffee")

      # creating expired reward
      customer_reward_3 = customer.grant_reward(reward_id: coffee_reward.id, quantity: 4,
                                                expires_at: DateTime.current.utc - 1.day)
      expect(customer_reward_3.gid.present?).to be true
      # Asserting Expired record not present
      get "/api/v1/customers/#{customer.gid}/customer-rewards", headers: api_request_headers
      expect(response).to have_http_status(200)
      response_json = response.parsed_body
      expect(response_json["customer_rewards"].size).to eql(1)
      expect(response_json["customer_rewards"][0]['id']).to eql(customer_reward_1.gid)
      expect(response_json["customer_rewards"][0]['quantity']).to eql(customer_reward_1.quantity)
      expect(response_json["customer_rewards"][0]['expires_at']).to eql(customer_reward_1.expires_at.to_time.iso8601)
      expect(response_json["customer_rewards"][0]['name']).to eql("Coffee")
    end
  end
end
