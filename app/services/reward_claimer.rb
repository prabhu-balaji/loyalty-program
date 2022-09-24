class RewardClaimer < ApplicationService
  def initialize(customer_id:, customer_reward_id:, quantity:)
    @customer_id = customer_id
    @customer_reward_id = customer_reward_id
    @quantity = quantity
  end

  def call
    customer = Customer.find_by_gid!(@customer_id)
    customer_reward = customer.customer_rewards.where(gid: @customer_reward_id,
                                                      status: CustomerReward::STATUS_MAPPING[:active]).first!
    validate_reward_criteria(customer_reward)
    update_reward_qty_and_status(customer_reward: customer_reward)
  end

  private

  def validate_reward_criteria(customer_reward)
    raise ApplicationBaseException.new(message: Constants::REWARD_EXPIRED_ERROR) if customer_reward.expired?
    raise ApplicationBaseException.new(message: Constants::INSUFFICIENT_QUANTITY) if @quantity > customer_reward.quantity
  end

  def update_reward_qty_and_status(customer_reward:)
    ActiveRecord::Base.transaction do
      update_parent_customer_reward(customer_reward.id)
      create_redeemed_reward(customer_reward)
    end
  end

  def update_parent_customer_reward(customer_reward_id)
    CustomerReward.update_counters(customer_reward_id, quantity: -@quantity)
  end

  def create_redeemed_reward(customer_reward)
    customer_reward.redeemed_customer_rewards.create!(
      reward_id: customer_reward.reward_id,
      customer_id: customer_reward.customer_id,
      reward_program_id: customer_reward.reward_program_id,
      quantity: @quantity,
      status: CustomerReward::STATUS_MAPPING[:redeemed]
    )
  end
end
