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
          transaction: { external_id: "random" }
        }, headers: api_request_headers
        expect(response).to have_http_status(400)
        response_json = response.parsed_body
        expect(response_json['description']).to eql("param is missing or the value is empty: amount")
      end

      it "should throw error for invalid region" do
        post '/api/v1/transactions', params: {
          transaction: { amount: "2", region_type: "random" }
        }, headers: api_request_headers
        expect(response).to have_http_status(400)
        response_json = response.parsed_body
        expect(response_json['description']).to eql(Constants::INVALID_TRANSACTION_REGION_TYPE)
      end

      it "should throw conflict for duplicate external_id" do
        transaction = FactoryBot.create(:transaction)
        post '/api/v1/transactions', params: {
          transaction: { amount: "2", external_id: transaction.external_id }
        }, headers: api_request_headers
        expect(response).to have_http_status(409)
        expect(response.parsed_body['description']).to eql('Transaction with external_id already exists')
      end
    end
    context 'success scenarios' do
      it "should create txn with just amount" do
        amount = "244.33"
        post '/api/v1/transactions', params: {
          transaction: { amount: amount }
        }, headers: api_request_headers
        expect(response).to have_http_status(201)
        response_json = response.parsed_body
        expect(response_json['id'].starts_with?('txn_')).to be true
        transaction_from_db = Transaction.find_by_gid(response_json['id'])
        expect(transaction_from_db.id.present?).to be true
        expect(transaction_from_db.transaction_date.to_s).to eql(transaction_from_db.created_at.to_s)
        expect(transaction_from_db.region_type).to eql(Transaction::REGION_TYPE[:domestic])
        expect(transaction_from_db.amount.to_f).to eql(amount.to_f)
      end

      it "should create domestic txn with fields" do
        external_id = KSUID.new.to_s
        amount = 5555.4434
        transaction_date = "2021-09-23T08:33:57+00:00"
        region_type = "DOMESTIC"
        post '/api/v1/transactions', params: {
          transaction: { amount: amount, external_id: external_id, transaction_date: transaction_date, region_type: region_type }
        }, headers: api_request_headers
        expect(response).to have_http_status(201)
        response_json = response.parsed_body
        expect(response_json['id'].starts_with?('txn_')).to be true
        transaction_from_db = Transaction.find_by_gid(response_json['id'])
        expect(transaction_from_db.id.present?).to be true
        expect(AppHelperMethods.standardize_datetime(transaction_from_db.transaction_date)).to eql(transaction_date.to_datetime.utc.in_time_zone.to_time.iso8601)
        expect(transaction_from_db.region_type).to eql(Transaction::REGION_TYPE[:domestic])
        expect(transaction_from_db.amount.to_f).to eql(amount.to_f)
        expect(transaction_from_db.external_id).to eql(external_id)
      end

      it "should create foreign txn with fields" do
        external_id = KSUID.new.to_s
        amount = 5555.4434
        transaction_date = "2021-09-23T08:33:57+00:00"
        region_type = "FOREIGN"
        post '/api/v1/transactions', params: {
          transaction: { amount: amount, external_id: external_id, transaction_date: transaction_date, region_type: region_type }
        }, headers: api_request_headers
        expect(response).to have_http_status(201)
        response_json = response.parsed_body
        expect(response_json['id'].starts_with?('txn_')).to be true
        transaction_from_db = Transaction.find_by_gid(response_json['id'])
        expect(transaction_from_db.id.present?).to be true
        expect(AppHelperMethods.standardize_datetime(transaction_from_db.transaction_date)).to eql(transaction_date.to_datetime.utc.in_time_zone.to_time.iso8601)
        expect(transaction_from_db.region_type).to eql(Transaction::REGION_TYPE[:foreign])
        expect(transaction_from_db.amount.to_f).to eql(amount.to_f)
        expect(transaction_from_db.external_id).to eql(external_id)
      end
    end
  end

  describe "GET /transactions/:id" do
    context 'error scenarios' do
      it "should return 404 for invalid transaction id" do
        get '/api/v1/transactions/random', headers: api_request_headers
        expect(response).to have_http_status(404)
        response_json = response.parsed_body
        expect(response_json['description']).to eql("Transaction not found")
      end
    end

    context 'success scenarios' do
      it "should return success for transaction" do
        external_id = KSUID.new.to_s
        amount = 200.38
        transaction_date = "2020-09-23T08:33:57+08:00"
        transaction = Transaction.create(external_id: external_id, amount: amount, transaction_date: transaction_date,
                                         region_type: Transaction::REGION_TYPE[:domestic])
        get "/api/v1/transactions/#{transaction.gid}", headers: api_request_headers
        expect(response).to have_http_status(200)
        response_json = response.parsed_body
        expect(response_json['amount']).to eql(amount.to_f.to_s)
        expect(response_json['external_id']).to eql(external_id)
      end
    end
  end
end
