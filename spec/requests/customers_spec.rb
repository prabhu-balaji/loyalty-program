require 'rails_helper'

RSpec.describe "Customers", type: :request do
  describe "POST /customers" do
    it "should successfully create a customer with specified parameters" do
      external_id = KSUID.new.to_s
      name = Faker::Name.name
      email = Faker::Internet.email
      birthday = Faker::Date.birthday.to_s
      post '/api/v1/customers', params: {
        customer: {
          name: name, email: email, birthday: birthday, external_id: external_id
        }
      }
      expect(response).to have_http_status(200)
      response_json = response.parsed_body
      customer_from_db = Customer.find_by_gid(response_json['id'])
      expect(customer_from_db.present?).to be true
      expect(response_json['created_at']) == customer_from_db.created_at.to_time.iso8601
      expect(response_json['updated_at']) == customer_from_db.created_at.to_time.iso8601
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
      }
      expect(response).to have_http_status(400)
      response_json = response.parsed_body
      expect(response_json['description'] == "Email is invalid")
    end
  end
end