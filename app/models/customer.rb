class Customer < ApplicationRecord
  include GidConcern

  has_many :transactions
  has_many :customer_points_entries
  has_many :customer_rewards

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  def grant_reward(reward_id:, quantity:, reward_program_id: nil)
    self.customer_rewards.create(
      reward_id: reward_id,
      reward_program_id: reward_program_id,
      quantity: quantity,
      status: CustomerReward::STATUS_MAPPING[:active]
    )
  end

  def grant_points(points:, transaction_id: nil)
    ActiveRecord::Base.transaction do
      self.customer_points_entries.create!(customer_id: self.id, points: points, transaction_id: transaction_id)
      Customer.update_counters(self.id, points: points)
    end
  end
end
