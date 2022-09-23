require 'rails_helper'

RSpec.describe "Transactions", type: :request do
  describe "POST /transactions" do
    context 'error scenarios' do
      it "should return 401 for unauthorized request" do
        post '/api/v1/transactions', params: {
          transaction: {
            amount: "233"
          }
        }, headers: { 'api-key': "random" }
        expect(response).to have_http_status(401)
        response_json = response.parsed_body
        expect(response_json['description']).to eql("Invalid api key")
      end
    end

    it "should throw error for empty amount" do
      post '/api/v1/transactions', params: {
        transaction: {}
      }, headers: api_request_headers
      expect(response).to have_http_status(400)
      response_json = response.parsed_body
      expect(response_json['description']).to eql("param is missing or the value is empty: transaction")
    end

    it "should throw error for empty body" do
      post '/api/v1/transactions', params: {}, headers: api_request_headers
      expect(response).to have_http_status(400)
      response_json = response.parsed_body
      expect(response_json['description']).to eql("param is missing or the value is empty: transaction")
    end

    it "should throw error for empty amount" do
      post '/api/v1/transactions', params: {
        transaction: {external_id: "random"}
      }, headers: api_request_headers
      expect(response).to have_http_status(400)
      response_json = response.parsed_body
      expect(response_json['description']).to eql("param is missing or the value is empty: amount")
    end

    it "should throw error for invalid region" do
      post '/api/v1/transactions', params: {
        transaction: {amount: "2", region_type: "random"}
      }, headers: api_request_headers
      expect(response).to have_http_status(400)
      response_json = response.parsed_body
      expect(response_json['description']).to eql(Constants::INVALID_TRANSACTION_REGION_TYPE)
    end

    it "should throw conflict for duplicate external_id" do
      transaction = FactoryBot.create(:transaction)
      post '/api/v1/transactions', params: {
        transaction: {amount: "2", external_id: transaction.external_id}
      }, headers: api_request_headers
      expect(response).to have_http_status(409)
      expect(response.parsed_body['description']).to eql('Transaction with external_id already exists')
    end
  end
end
