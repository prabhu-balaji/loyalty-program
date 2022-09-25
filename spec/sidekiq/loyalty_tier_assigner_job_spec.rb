require 'rails_helper'
RSpec.describe LoyaltyTierAssignerJob, type: :job do
  def customer_coffee_rewards(customer)
    customer.customer_rewards.where(reward_id: coffee_reward.id, reward_program_id: coffee_reward_program[:id])
  end

  def create_customer_points_entry(customer:, points: 100, created_at:)
    transaction = customer.transactions.create!(amount: 0)
    customer.customer_points_entries.create!(transaction_id: transaction.id, points: points, created_at: created_at)
  end

  it "should test LoyaltyTierAssignerJob Job for standard customer" do
    assert YAML.load_file("config/schedule.yml")["loyalty_tier_assigner"]["cron"] == "0 4 1 * *"
    #### Create a customer and check for standard loyalty tier####
    customer = FactoryBot.create(:customer)
    LoyaltyTierAssignerJob.new.perform
    expect(customer.reload.tier_id).to eql(Constants::CUSTOMER_TIERS[:standard])

    # Creating customer points < 1000 in both cycles
    create_customer_points_entry(customer: customer, points: 999,
                                 created_at: (DateTime.current.utc - 1.month))
    create_customer_points_entry(customer: customer, points: 999,
                                 created_at: (DateTime.current.utc - 2.months))

    create_customer_points_entry(customer: customer, points: 10000,
                                 created_at: DateTime.current.utc) # current cycle shouldnt affect
    LoyaltyTierAssignerJob.new.perform
    expect(customer.reload.tier_id).to eql(Constants::CUSTOMER_TIERS[:standard])
  end

  it "should test LoyaltyTierAssignerJob Job for gold customer" do
    #### Create a customer and check for standard loyalty tier####
    customer = FactoryBot.create(:customer)
    expect(customer.tier_id).to eql(Constants::CUSTOMER_TIERS[:standard])

    # Creating customer points sum > 1000 in one cycle and < 1000 in another cycle. Maximum of both cycles should be considered for loyalty tier calculation.
    # cycle 1
    create_customer_points_entry(customer: customer, points: 999,
                                 created_at: (DateTime.current.utc - 1.month))
    create_customer_points_entry(customer: customer, points: 1,
                                 created_at: (DateTime.current.utc - 1.month))
    # cycle 2
    create_customer_points_entry(customer: customer, points: 998,
                                 created_at: (DateTime.current.utc - 2.months))
    create_customer_points_entry(customer: customer, points: 1,
                                 created_at: (DateTime.current.utc - 2.months))

    LoyaltyTierAssignerJob.new.perform
    expect(customer.reload.tier_id).to eql(Constants::CUSTOMER_TIERS[:gold])

    # Testing case by keeping points > 1000 & < 5000
    # Creating customer points sum > 1000 in one cycle and < 1000 in another cycle. Maximum of both cycles should be considered for loyalty tier calculation.
    # adding another 1000 points to cycle 1, bringing total points to 2000 in that cycle
    create_customer_points_entry(customer: customer, points: 1000,
                                 created_at: (DateTime.current.utc - 1.month))
    LoyaltyTierAssignerJob.new.perform
    expect(customer.reload.tier_id).to eql(Constants::CUSTOMER_TIERS[:gold])
  end

  it "should test LoyaltyTierAssignerJob Job for platinum customer" do
    #### Create a customer and check for standard loyalty tier####
    customer = FactoryBot.create(:customer)
    expect(customer.tier_id).to eql(Constants::CUSTOMER_TIERS[:standard])

    # Creating customer points sum > 1000 in one cycle and < 1000 in another cycle. Maximum of both cycles should be considered for loyalty tier calculation.
    # cycle 1
    create_customer_points_entry(customer: customer, points: 2999,
                                 created_at: (DateTime.current.utc - 1.month))
    create_customer_points_entry(customer: customer, points: 1,
                                 created_at: (DateTime.current.utc - 1.months))
    # cycle 2
    create_customer_points_entry(customer: customer, points: 4999,
                                 created_at: (DateTime.current.utc - 2.months))
    create_customer_points_entry(customer: customer, points: 1,
                                 created_at: (DateTime.current.utc - 2.months))

    LoyaltyTierAssignerJob.new.perform
    expect(customer.reload.tier_id).to eql(Constants::CUSTOMER_TIERS[:platinum])

    # adding few more points and confirming
    create_customer_points_entry(customer: customer, points: 1000,
                                 created_at: (DateTime.current.utc - 2.months))
    LoyaltyTierAssignerJob.new.perform
    expect(customer.reload.tier_id).to eql(Constants::CUSTOMER_TIERS[:platinum])
  end
end
