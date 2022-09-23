class Transaction < ApplicationRecord
  include GidConcern

  REGION_TYPE = {
    domestic: 1,
    foreign: 2
  }.freeze

  validates_presence_of :amount

  before_validation :prefill_region
  before_create :prefill_transaction_date

  private

  def prefill_transaction_date
    self.transaction_date ||= self.created_at
  end

  def prefill_region
    self.region_type ||= REGION_TYPE[:domestic]
  end
end
