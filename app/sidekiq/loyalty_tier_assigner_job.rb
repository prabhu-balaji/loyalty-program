class LoyaltyTierAssignerJob
  include Sidekiq::Job

  def perform(*args)
    logger.info("Running LoyaltyTierAssignerJob :: #{DateTime.current.to_s}")
    Customer.find_each(batch_size: 200).each do |customer|
      begin
        assign_loyalty_tier(customer)
      rescue StandardError => exception
        logger.error("LoyaltyTierAssignerJob::Error for customer #{customer.id} :: #{exception.message}")
      end
    end
  end

  private

  def assign_loyalty_tier(customer)
    tier_id = calculate_loyalty_tier(customer)
    customer.update!(tier_id: tier_id) if tier_id != customer.tier_id
  end

  def calculate_loyalty_tier(customer)
    loyalty_points = [points_accumulated_in_cycle(customer: customer, cycle: 1),
                      points_accumulated_in_cycle(customer: customer, cycle: 2)].max
    if loyalty_points >= 5000
      Constants::CUSTOMER_TIERS[:platinum]
    elsif loyalty_points >= 1000
      Constants::CUSTOMER_TIERS[:gold]
    else
      Constants::CUSTOMER_TIERS[:standard]
    end
  end

  def start_date_for_cycle(cycle)
    (DateTime.current.utc - cycle.months).beginning_of_month
  end

  def end_date_for_cycle(cycle)
    (DateTime.current.utc - cycle.months).end_of_month
  end

  def points_accumulated_in_cycle(customer:, cycle:) # cycle argument denotes how many cycles before to calculate points. 1 means previous cycle and  2 means one cycle before that.
    customer.customer_points_entries.where(
      "created_at >= :start_date and created_at <= :end_date and transaction_id is not NULL", {
        start_date: start_date_for_cycle(cycle), end_date: end_date_for_cycle(cycle)
      }
    ).sum(:points) # we are only considering points from transactions & not bonus points
  end
end
