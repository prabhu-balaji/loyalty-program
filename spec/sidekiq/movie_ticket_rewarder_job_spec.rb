require 'rails_helper'
RSpec.describe MovieTicketRewarderJob, type: :job do
  before(:all) do
    Customer.delete_all # To reduce time taken to execute
  end

  after(:all) do
    Customer.delete_all
  end

  it "should not consider customers with first txn beyond last 60 days" do
    assert Sidekiq::Cron::Job.find("movie_ticket_rewarder").cron == "0 1 * * *"
    customer = FactoryBot.create(:customer)

    MovieTicketRewarderJob.new.perform
    expect(customer.customer_rewards.to_a.size).to eql(0)

    customer.transactions.create(amount: 10000, created_at: DateTime.current.utc - 61.days)
    MovieTicketRewarderJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(0)
  end

  it "should not consider customers with first txn within 60 days and sum of txns <= 1000" do
    customer = FactoryBot.create(:customer)

    customer.transactions.create(amount: 900, created_at: DateTime.current.utc - 40.days)
    MovieTicketRewarderJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(0)

    customer.transactions.create(amount: 99, created_at: DateTime.current.utc - 1.days)
    MovieTicketRewarderJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(0)

    customer.transactions.create(amount: 1, created_at: DateTime.current.utc - 1.days)
    MovieTicketRewarderJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(0)
  end

  it "should consider customer with first txn within 60 days and single txn > 1000" do
    customer = FactoryBot.create(:customer)

    customer.transactions.create(amount: 1001, created_at: DateTime.current.utc - 40.days)
    MovieTicketRewarderJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(1)
    customer_reward = customer.customer_rewards.first
    expect(customer_reward.reward_id).to eql(movie_reward.id)
    expect(customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(customer_reward.quantity).to eql(1)

    ## Rerunning should not add it again
    MovieTicketRewarderJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(1)
    customer_reward = customer.customer_rewards.first
    expect(customer_reward.reward_id).to eql(movie_reward.id)
    expect(customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(customer_reward.quantity).to eql(1)
  end

  it "should consider customer with first txn within 60 days and multiple txn sum > 1000" do
    customer = FactoryBot.create(:customer)

    customer.transactions.create(amount: 900, created_at: DateTime.current.utc - 40.days)
    MovieTicketRewarderJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(0)

    customer.transactions.create(amount: 101, created_at: DateTime.current.utc - 40.days)
    MovieTicketRewarderJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(1)
    customer_reward = customer.customer_rewards.first
    expect(customer_reward.reward_id).to eql(movie_reward.id)
    expect(customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(customer_reward.quantity).to eql(1)

    ## Rerunning should not add it again
    MovieTicketRewarderJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(1)
    customer_reward = customer.customer_rewards.first
    expect(customer_reward.reward_id).to eql(movie_reward.id)
    expect(customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(customer_reward.quantity).to eql(1)
  end

  it "should consider customer with first txn 60 days back and multiple txn sum > 1000" do
    customer = FactoryBot.create(:customer)

    customer.transactions.create(amount: 900, created_at: DateTime.current.utc - 60.days)
    MovieTicketRewarderJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(0)

    customer.transactions.create(amount: 101, created_at: DateTime.current.utc - 1.day)
    MovieTicketRewarderJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(1)
    customer_reward = customer.customer_rewards.first
    expect(customer_reward.reward_id).to eql(movie_reward.id)
    expect(customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(customer_reward.quantity).to eql(1)

    ## Rerunning should not add it again
    MovieTicketRewarderJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(1)
    customer_reward = customer.customer_rewards.first
    expect(customer_reward.reward_id).to eql(movie_reward.id)
    expect(customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(customer_reward.quantity).to eql(1)
  end
end
