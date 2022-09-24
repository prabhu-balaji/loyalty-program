class CustomerReward < ApplicationRecord
  include GidConcern

  belongs_to :customer
  belongs_to :reward

  has_many :redeemed_customer_rewards, class_name: "CustomerReward", foreign_key: "parent_customer_reward_id"
  belongs_to :parent_customer_reward, class_name: "CustomerReward", foreign_key: "parent_customer_reward_id",
                                      optional: true

  validates_presence_of :status, :quantity

  STATUS_MAPPING = {
    active: 1,
    redeemed: 2
  }.freeze

  def expired?
    @expired ||= self.expires_at.present? && self.expires_at < DateTime.current.utc
  end
end
