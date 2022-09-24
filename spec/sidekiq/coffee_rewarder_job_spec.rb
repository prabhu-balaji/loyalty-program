require 'rails_helper'
RSpec.describe CoffeeRewarderJob, type: :job do
  def customer_coffee_rewards(customer)
    customer.customer_rewards.where(reward_id: coffee_reward.id, reward_program_id: coffee_reward_program[:id])
  end

  def create_customer_points_entry(customer:, points: 100, created_at:)
    transaction = customer.transactions.create(amount: 0)
    customer.customer_points_entries.create(transaction_id: transaction.id, points: points, created_at: created_at)
  end

  it "should test CoffeeRewarder Job" do
    assert Sidekiq::Cron::Job.find("coffee_rewarder").cron == "0 0 1 * *"
    #### Create 3 customers and points entries in prev month, current month and 2 months before, respectively. All above 100 points. ####
    primary_customer = FactoryBot.create(:customer)
    secondary_customer_1 = FactoryBot.create(:customer)
    secondary_customer_2 = FactoryBot.create(:customer)

    create_customer_points_entry(customer: primary_customer, points: 100,
                                 created_at: (DateTime.current.utc - 1.month))
    create_customer_points_entry(customer: secondary_customer_1, points: 100,
                                 created_at: (DateTime.current.utc))
    create_customer_points_entry(customer: secondary_customer_2, points: 100,
                                 created_at: DateTime.current.utc - 2.months)

    [primary_customer, secondary_customer_1, secondary_customer_2].each { |customer|
      expect(customer.customer_points_entries.sum(:points)).to eql(100)
    }

    ## Run worker ##
    CoffeeRewarderJob.new.perform
    primary_customer_rewards = customer_coffee_rewards(primary_customer)
    expect(primary_customer_rewards.to_a.size).to eql(1)
    primary_customer_reward = primary_customer_rewards.first
    expect(primary_customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(primary_customer_reward.quantity).to eql(1)

    [secondary_customer_1, secondary_customer_2].each { |customer|
      expect(customer_coffee_rewards(customer).to_a.size).to eql(0)
    }

    # Rerunning worker should not grant points again.
    CoffeeRewarderJob.new.perform
    primary_customer_rewards = customer_coffee_rewards(primary_customer)
    expect(primary_customer_rewards.to_a.size).to eql(1)
    primary_customer_reward = primary_customer_rewards.first
    expect(primary_customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(primary_customer_reward.quantity).to eql(1)
  end

  it "should test CoffeeRewarder Job for sum query" do
    #### Create customers and 3 points entries in prev month. Sum is < 100 points for one customer and sum > 100 points for another customer. ####
    primary_customer = FactoryBot.create(:customer)
    secondary_customer = FactoryBot.create(:customer)

    # Granting 180 points in total to primary customer
    create_customer_points_entry(customer: primary_customer, points: 80,
                                 created_at: (DateTime.current.utc - 1.month))
    create_customer_points_entry(customer: primary_customer, points: 100,
                                 created_at: (DateTime.current.utc - 1.month))

    # Granting 99 points in total to secondary customer
    create_customer_points_entry(customer: secondary_customer, points: 98,
                                 created_at: (DateTime.current.utc - 1.month))
    create_customer_points_entry(customer: secondary_customer, points: 1,
                                 created_at: (DateTime.current.utc - 1.month))

    expect(primary_customer.customer_points_entries.sum(:points)).to eql(180)
    expect(secondary_customer.customer_points_entries.sum(:points)).to eql(99)

    ## Run worker ##
    CoffeeRewarderJob.new.perform
    primary_customer_rewards = customer_coffee_rewards(primary_customer)
    expect(primary_customer_rewards.to_a.size).to eql(1)
    primary_customer_reward = primary_customer_rewards.first
    expect(primary_customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(primary_customer_reward.quantity).to eql(1)

    expect(customer_coffee_rewards(secondary_customer).to_a.size).to eql(0)

    # Rerunning worker should not grant points again.
    CoffeeRewarderJob.new.perform
    primary_customer_rewards = customer_coffee_rewards(primary_customer)
    expect(primary_customer_rewards.to_a.size).to eql(1)
    primary_customer_reward = primary_customer_rewards.first
    expect(primary_customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(primary_customer_reward.quantity).to eql(1)
    expect(customer_coffee_rewards(secondary_customer).to_a.size).to eql(0)
  end
end
