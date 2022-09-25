require 'rails_helper'
RSpec.describe QuarterlyBonusJob, type: :job do
  before(:all) do
    Customer.delete_all # To reduce time taken to execute
  end

  after(:all) do
    Customer.delete_all
  end

  def previous_quarter_beginning
    (DateTime.current.utc - 3.months).beginning_of_quarter
  end

  def quarterly_bonus_point_entries(customer)
    customer.customer_points_entries.where(reward_program_id: quarterly_bonus_reward_program[:id]).to_a
  end

  it "should not consider customers with no txn for last quarter" do
    assert YAML.load_file("config/schedule.yml")["quarterly_rewarder"]["cron"] == "0 3 1 */3 *"
    customer = FactoryBot.create(:customer)

    QuarterlyBonusJob.new.perform
    expect(customer.customer_points_entries.to_a.size).to eql(0)

    customer.transactions.create(amount: 10000, transaction_date: DateTime.current.utc)
    QuarterlyBonusJob.new.perform
    expect(quarterly_bonus_point_entries(customer.reload).size).to eql(0)

    customer.transactions.create(amount: 10000, transaction_date: DateTime.current.utc - 6.months)
    QuarterlyBonusJob.new.perform
    expect(quarterly_bonus_point_entries(customer.reload).size).to eql(0)
  end

  it "should not consider customers with txn sum <= 2000 for last quarter" do
    assert YAML.load_file("config/schedule.yml")["quarterly_rewarder"]["cron"] == "0 3 1 */3 *"
    customer = FactoryBot.create(:customer)

    customer.transactions.create(amount: 1999, created_at: DateTime.current.utc - 3.months)
    QuarterlyBonusJob.new.perform
    expect(quarterly_bonus_point_entries(customer.reload).size).to eql(0)

    customer.transactions.create(amount: 1, created_at: DateTime.current.utc - 3.months)
    QuarterlyBonusJob.new.perform
    expect(quarterly_bonus_point_entries(customer.reload).size).to eql(0)
  end

  it "should consider customers with single txn > 2000 for last quarter" do
    assert YAML.load_file("config/schedule.yml")["quarterly_rewarder"]["cron"] == "0 3 1 */3 *"
    customer = FactoryBot.create(:customer)

    customer.transactions.create(amount: 2001, created_at: DateTime.current.utc - 3.months)
    QuarterlyBonusJob.new.perform
    customer_points_entries = quarterly_bonus_point_entries(customer.reload).to_a
    expect(customer_points_entries.size).to eql(1)
    customer_points_entry = customer_points_entries.first
    expect(customer_points_entry.reward_program_id).to eql(quarterly_bonus_reward_program[:id])
    expect(customer_points_entry.points).to eql(100)
    expect(customer_points_entry.transaction_id).to be nil

    ## Rerunning should not add it again
    QuarterlyBonusJob.new.perform
    customer_points_entries = quarterly_bonus_point_entries(customer.reload).to_a
    expect(customer_points_entries.size).to eql(1)
    customer_points_entry = customer_points_entries.first
    expect(customer_points_entry.reward_program_id).to eql(quarterly_bonus_reward_program[:id])
    expect(customer_points_entry.points).to eql(100)
    expect(customer_points_entry.transaction_id).to be nil
  end

  it "should consider customer multiple txns sum > 1000 in last quarter" do
    customer = FactoryBot.create(:customer)

    customer.transactions.create(amount: 1800, created_at: DateTime.current.utc - 3.months)
    customer.transactions.create(amount: 199, created_at: previous_quarter_beginning + 1.month)
    customer.transactions.create(amount: 299, created_at: previous_quarter_beginning + 1.month + 3.days)
    QuarterlyBonusJob.new.perform
    customer_points_entries = quarterly_bonus_point_entries(customer.reload).to_a
    expect(customer_points_entries.size).to eql(1)
    customer_points_entry = customer_points_entries.first
    expect(customer_points_entry.reward_program_id).to eql(quarterly_bonus_reward_program[:id])
    expect(customer_points_entry.points).to eql(100)
    expect(customer_points_entry.transaction_id).to be nil

    ## Rerunning should not add it again
    QuarterlyBonusJob.new.perform
    customer_points_entries = quarterly_bonus_point_entries(customer.reload).to_a
    expect(customer_points_entries.size).to eql(1)
    customer_points_entry = customer_points_entries.first
    expect(customer_points_entry.reward_program_id).to eql(quarterly_bonus_reward_program[:id])
    expect(customer_points_entry.points).to eql(100)
    expect(customer_points_entry.transaction_id).to be nil
  end
end
