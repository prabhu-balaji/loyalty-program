module HelperMethods
  def api_request_headers
    { 'api-key' => Rails.application.credentials.api_key, 'content_type' => 'application/json' }
  end

  def create_customer_via_api
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
    response.parsed_body['id']
  end

  def create_transaction_via_api(amount: 100, region_type: "DOMESTIC", customer_gid:)
    external_id = KSUID.new.to_s
    amount = amount
    post '/api/v1/transactions', params: {
      transaction: { amount: amount, external_id: external_id, region_type: region_type, customer_id: customer_gid }
    }, headers: api_request_headers
    expect(response).to have_http_status(201)
    response.parsed_body['id']
  end
end
