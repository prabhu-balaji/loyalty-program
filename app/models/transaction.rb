class Transaction < ApplicationRecord
  include GidConcern

  has_one :customer_points_entry

  REGION_TYPE = {
    domestic: 1,
    foreign: 2
  }.freeze

  belongs_to :customer

  validates_presence_of :amount

  before_validation :prefill_region
  before_create :prefill_transaction_date

  after_commit :evaluate_points, on: :create

  private

  def prefill_transaction_date
    self.transaction_date ||= self.created_at
  end

  def prefill_region
    self.region_type ||= REGION_TYPE[:domestic]
  end

  def evaluate_points
    # Logic should ideally come from reward_programs where different rules are configured for different merchants/accounts. Hardcoding for now.
    # This entire block should be run on background in sidekiq. For now, its run on after_commit.
    points = (self.amount.to_i / Constants::PER_DOLLARS_TO_ADD_POINTS) * Constants::POINTS_MULTIPLIER # We assume that amount is always sent in $ for now.
    points *= Constants::FOREIGN_ADDITIONAL_MULTIPLIER if self.region_type == REGION_TYPE[:foreign]
    add_points_for_transaction(points) if points > 0 # Not creating entry when points = 0
  end

  def add_points_for_transaction(points)
    begin
      ActiveRecord::Base.transaction do
        self.create_customer_points_entry!(customer_id: self.customer_id, points: points)
        Customer.update_counters(self.customer_id, points: points)
      end
    rescue StandardError => exception
      logger.error "Failed while adding points for transaction :: transaction_id: #{self.id} :: #{exception.message}"
    end
  end
end
