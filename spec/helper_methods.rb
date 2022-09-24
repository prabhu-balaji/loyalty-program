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

  def coffee_reward_program
    @coffee_reward_program ||= Constants::REWARD_PROGRAMS.find { |reward_program|
      reward_program[:name].eql?('coffee_reward_program')
    }
  end

  def coffee_reward
    @coffee_reward = Reward.find_by_name(Constants::REWARDS_MAPPING[:coffee])
  end

  def movie_reward_program
    @movie_reward_program ||= Constants::REWARD_PROGRAMS.find { |reward_program|
      reward_program[:name].eql?('movie_reward_program')
    }
  end

  def movie_reward
    @movie_reward ||= Reward.find_by_name(Constants::REWARDS_MAPPING[:movie_ticket])
  end

  def cash_rebate_program
    @cash_rebate_program ||= Constants::REWARD_PROGRAMS.find { |reward_program|
      reward_program[:name].eql?('cash_rebate_program')
    }
  end

  def cash_rebate_reward
    @cash_rebate_reward ||= Reward.find_by_name(Constants::REWARDS_MAPPING[:cash_rebate])
  end

  def birthday_reward_program
    @birthday_reward_program ||= Constants::REWARD_PROGRAMS.find { |reward_program|
      reward_program[:name].eql?('birthday_reward_program')
    }
  end

  def lounge_access_reward
    @lounge_access_reward ||= Reward.find_by_name(Constants::REWARDS_MAPPING[:lounge_access])
  end

  def lounge_access_reward_program
    @lounge_access_reward_program ||= Constants::REWARD_PROGRAMS.find { |reward_program|
      reward_program[:name].eql?('lounge_access_reward_program')
    }
  end
end
