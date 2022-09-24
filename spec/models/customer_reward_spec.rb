require 'rails_helper'

RSpec.describe CustomerReward, type: :model do
  it "should create a reward record with fields" do
    expect(CustomerReward.new.valid?).to be false
    reward = FactoryBot.create(:reward)
    customer = FactoryBot.create(:customer)
    # validate presence of status & qty
    expect(CustomerReward.new(customer_id: customer.id, reward_id: reward.id, status: 1).valid?).to be false
    expect(CustomerReward.new(customer_id: customer.id, reward_id: reward.id, quantity: 1).valid?).to be false

    customer_reward = CustomerReward.create(customer_id: customer.id, reward_id: reward.id, status: 1, quantity: 4)
    expect(customer_reward.id.present?).to be true
    expect(customer_reward.gid.starts_with?('cus_rew_')).to be true
    customer_reward.destroy
    expect(CustomerReward.find_by_id(customer_reward.id)).to be nil
  end
end
