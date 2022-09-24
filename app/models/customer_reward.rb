class CustomerReward < ApplicationRecord
  include GidConcern

  belongs_to :customer
  belongs_to :reward

  has_many :redeemed_customer_rewards, class_name: "CustomerReward", foreign_key: "parent_customer_reward_id"
  belongs_to :parent_customer_reward, class_name: "CustomerReward", foreign_key: "parent_customer_reward_id",
                                      optional: true

  scope :available_rewards, -> {
                              where("(expires_at is NULL or expires_at > (?)) and status = (?)", DateTime.current.utc, STATUS_MAPPING[:active])
                            }

  validates_presence_of :status, :quantity

  before_validation :format_expires_at

  STATUS_MAPPING = {
    active: 1,
    redeemed: 2
  }.freeze

  def expired?
    @expired ||= self.expires_at.present? && self.expires_at < DateTime.current.utc
  end

  private

  def format_expires_at # Keeping expiry at EOD for now.
    self.expires_at = self.expires_at.end_of_day if self.expires_at.present?
  end
end
