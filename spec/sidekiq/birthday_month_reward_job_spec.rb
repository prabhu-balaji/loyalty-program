require 'rails_helper'
RSpec.describe BirthdayMonthRewardJob, type: :job do
  before(:all) do
    Customer.delete_all # To reduce time taken to execute
  end

  after(:all) do
    Customer.delete_all
  end

  def customer_coffee_rewards(customer)
    customer.customer_rewards.where(reward_id: coffee_reward.id, reward_program_id: birthday_reward_program[:id])
  end

  it "should test BirthdayMonthRewardJob Job" do
    assert YAML.load_file("config/schedule.yml")["birthday_rewarder"]["cron"] == "0 2 1 * *"
    #### Create 3 customers and entries with birthdays in prev month, current month and empty birthday ####
    current_month = DateTime.current.month
    customer_1 = Customer.create(name: Faker::Name.name,
                                 birthday: Faker::Date.in_date_period(year: 1997,
                                                                      month: current_month))
    customer_2 = Customer.create(name: Faker::Name.name,
                                 birthday: Faker::Date.in_date_period(year: 1965,
                                                                      month: current_month + 1))
    customer_3 = Customer.create(name: Faker::Name.name,
                                 birthday: Faker::Date.in_date_period(year: 2018,
                                                                      month: current_month - 1))

    ## Run worker ##
    BirthdayMonthRewardJob.new.perform
    primary_customer_rewards = customer_coffee_rewards(customer_1)
    expect(primary_customer_rewards.to_a.size).to eql(1)
    primary_customer_reward = primary_customer_rewards.first
    expect(primary_customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(primary_customer_reward.quantity).to eql(1)

    [customer_2, customer_3].each { |customer|
      expect(customer_coffee_rewards(customer).to_a.size).to eql(0)
    }

    # Rerunning worker should not grant points again.
    BirthdayMonthRewardJob.new.perform
    primary_customer_rewards = customer_coffee_rewards(customer_1)
    expect(primary_customer_rewards.to_a.size).to eql(1)
    primary_customer_reward = primary_customer_rewards.first
    expect(primary_customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(primary_customer_reward.quantity).to eql(1)
  end
end
