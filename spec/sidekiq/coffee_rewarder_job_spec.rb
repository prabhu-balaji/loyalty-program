require 'rails_helper'
RSpec.describe CoffeeRewarderJob, type: :job do
  def coffee_reward_program
    @coffee_reward_program ||= Constants::REWARD_PROGRAMS.find { |reward_program|
      reward_program[:name].eql?('coffee_reward_per_calendar_month')
    }
  end

  def coffee_reward
    @coffee_reward = Reward.find_by_name('coffee')
  end

  def customer_coffee_rewards(customer)
    customer.customer_rewards.where(reward_id: coffee_reward.id, reward_program_id: coffee_reward_program[:id])
  end

  def create_customer_points_entry(customer:, amount:, points: 100, created_at:)
    transaction = customer.transactions.create(amount: amount)
    customer.customer_points_entries.destroy_all
    customer.customer_points_entries.create(transaction_id: transaction.id, points: 100, created_at: created_at)
  end

  it "should test CoffeeRewarder Job" do
    #### Create 3 customers and points entries in prev month, current month and 2 months before, respectively. All above 100 points. ####
    primary_customer = FactoryBot.create(:customer)
    secondary_customer_1 = FactoryBot.create(:customer)
    secondary_customer_2 = FactoryBot.create(:customer)

    create_customer_points_entry(customer: primary_customer, amount: 100, points: 100,
                                 created_at: (DateTime.current - 1.month))
    create_customer_points_entry(customer: secondary_customer_1, amount: 100, points: 100,
                                 created_at: (DateTime.current))
    create_customer_points_entry(customer: secondary_customer_2, amount: 100, points: 100,
                                 created_at: DateTime.current - 2.months)

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
end
