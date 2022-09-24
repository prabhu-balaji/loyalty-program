class CustomerReward < ApplicationRecord
  belongs_to :customer
  belongs_to :reward

  validates_presence_of :status, :quantity
end
