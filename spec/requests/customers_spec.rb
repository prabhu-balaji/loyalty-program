require 'rails_helper'

RSpec.describe "Customers", type: :request do
  describe "POST /customers" do
    it "should return 401 for unauthorized request" do
      post '/api/v1/customers', params: {
        customer: {
          name: "random"
        }
      }, headers: { 'api-key': "random" }
      expect(response).to have_http_status(401)
      response_json = response.parsed_body
      expect(response_json['description']).to eql("Invalid api key")
    end

    it "should successfully create a customer with specified parameters" do
      external_id = KSUID.new.to_s
      name = Faker::Name.name
      email = Faker::Internet.email
      birthday = Faker::Date.birthday.to_s
      post '/api/v1/customers', params: {
        customer: {
          name: name, email: email, birthday: birthday, external_id: external_id
        }
      }, headers: api_request_headers
      expect(response).to have_http_status(201)
      response_json = response.parsed_body
      customer_from_db = Customer.find_by_gid(response_json['id'])
      expect(customer_from_db.present?).to be true
      expect(customer_from_db.name).to eql(name)
      expect(customer_from_db.external_id).to eql(external_id)
      expect(customer_from_db.email).to eql(email)
      expect(customer_from_db.birthday.to_s).to eql(birthday)
    end

    it "should throw error for customer with invalid email" do
      post '/api/v1/customers', params: {
        customer: {
          email: "random"
        }
      }, headers: api_request_headers
      expect(response).to have_http_status(400)
      response_json = response.parsed_body
      expect(response_json['description']).to eql("Email is invalid")
    end

    it "should throw 409 for customer with duplicate external id" do
      customer = FactoryBot.create(:customer)
      # Trying to create customer with duplicate external_id
      post '/api/v1/customers', params: {
        customer: {
          external_id: customer.external_id
        }
      }, headers: api_request_headers
      expect(response).to have_http_status(409)
      expect(response.parsed_body['description']).to eql('Customer with external_id already exists')
    end
  end

  describe "GET /customers/:id" do
    it "should throw 404 for invalid customer id" do
      get '/api/v1/customers/random', headers: api_request_headers
      expect(response).to have_http_status(404)
      expect(response.parsed_body['description']).to eql('Customer not found')
    end

    it "should give 200 with response for valid customers" do
      external_id = KSUID.new.to_s
      name = Faker::Name.name
      email = Faker::Internet.email
      birthday = Faker::Date.birthday.to_s
      customer = Customer.create(name: name, email: email, external_id: external_id, birthday: birthday)
      get "/api/v1/customers/#{customer.gid}", headers: api_request_headers
      expect(response).to have_http_status(200)
      response_json = response.parsed_body
      expect(response_json['name']).to eql(customer.name)
      expect(response_json['birthday']).to eql(customer.birthday.to_s)
      expect(response_json['email']).to eql(customer.email)
      expect(response_json['external_id']).to eql(customer.external_id)
      expect(response_json['created_at']).to eql(customer.created_at.to_time.iso8601)

      # Making columns empty and checking response
      customer.update_attributes(name: nil, email: nil, birthday: nil)
      get "/api/v1/customers/#{customer.gid}", headers: api_request_headers
      expect(response).to have_http_status(200)
      response_json = response.parsed_body
      expect(response_json['name']).to be nil
      expect(response_json['birthday']).to be nil
      expect(response_json['email']).to be nil
      expect(response_json['external_id']).to eql(customer.external_id)
      expect(response_json['created_at']).to eql(customer.created_at.to_time.iso8601)
    end
  end
end
