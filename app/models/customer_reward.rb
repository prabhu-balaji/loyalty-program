class CustomerReward < ApplicationRecord
  include GidConcern

  belongs_to :customer
  belongs_to :reward

  validates_presence_of :status, :quantity

  STATUS_MAPPING = {
    active: 1,
    redeemed: 2
  }.freeze

  def expired?
    @expired ||= self.expires_at.present? && self.expires_at < DateTime.current.utc
  end
end
