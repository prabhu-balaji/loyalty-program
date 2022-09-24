require 'rails_helper'
RSpec.describe CashRebateJob, type: :job do
  before(:all) do
    Customer.delete_all # To reduce time taken to execute
  end

  after(:all) do
    Customer.delete_all
  end

  it "should test various conditions" do
    assert YAML.load_file("config/schedule.yml")["cash_rebate_awarder"]["cron"] == "0 3 1 * *"
    customer = FactoryBot.create(:customer)

    CashRebateJob.new.perform
    expect(customer.customer_rewards.to_a.size).to eql(0)

    10.times { customer.transactions.create(amount: 101, created_at: DateTime.current.utc - 2.months) }
    10.times { customer.transactions.create(amount: 101, created_at: DateTime.current.utc) }

    CashRebateJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(0)

    # Creating 9 txns in previous month with 101$
    9.times { customer.transactions.create(amount: 101, created_at: DateTime.current.utc - 1.months) }
    CashRebateJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(0)

    # creating one more txn with 101$ in previous month
    customer.transactions.create(amount: 101, created_at: DateTime.current.utc - 1.months)
    CashRebateJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(1)

    customer_reward = customer.customer_rewards.first
    expect(customer_reward.reward_id).to eql(cash_rebate_reward.id)
    expect(customer_reward.reward_program_id).to eql(cash_rebate_program[:id])
    expect(customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(customer_reward.quantity).to eql(1)

    ## verifying it doesnt recalculate ##
    CashRebateJob.new.perform
    customer_reward = customer.reload.customer_rewards.first
    expect(customer_reward.reward_id).to eql(cash_rebate_reward.id)
    expect(customer_reward.reward_program_id).to eql(cash_rebate_program[:id])
    expect(customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(customer_reward.quantity).to eql(1)
  end

  it "should test various success scenarios" do
    customer = FactoryBot.create(:customer)

    # Creating 11 txns in previous month with 200$
    11.times { customer.transactions.create(amount: 200, created_at: DateTime.current.utc - 1.months) }
    CashRebateJob.new.perform
    expect(customer.reload.customer_rewards.to_a.size).to eql(1)

    customer_reward = customer.customer_rewards.first
    expect(customer_reward.reward_id).to eql(cash_rebate_reward.id)
    expect(customer_reward.reward_program_id).to eql(cash_rebate_program[:id])
    expect(customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(customer_reward.quantity).to eql(1)

    ## verifying it doesnt recalculate ##
    CashRebateJob.new.perform
    customer_reward = customer.reload.customer_rewards.first
    expect(customer_reward.reward_id).to eql(cash_rebate_reward.id)
    expect(customer_reward.reward_program_id).to eql(cash_rebate_program[:id])
    expect(customer_reward.status).to eql(CustomerReward::STATUS_MAPPING[:active])
    expect(customer_reward.quantity).to eql(1)
  end
end
