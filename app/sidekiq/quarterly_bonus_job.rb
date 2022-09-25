class QuarterlyBonusJob
  include Sidekiq::Job

  def perform(*args)
    logger.info("Running QuarterlyBonusJob :: #{DateTime.current.to_s}")
    Customer.find_each(batch_size: 200).each do |customer|
      begin
        reward_points(customer) if eligible_for_quarterly_bonus?(customer)
      rescue StandardError => exception
        logger.error("QuarterlyBonusJob::Error for customer #{customer.id} :: #{exception.message}")
      end
    end
  end

  private

  def eligible_for_quarterly_bonus?(customer)
    return false if reward_already_granted?(customer)

    transaction_sum = customer.transactions.where(
      "transaction_date >= :start_date and transaction_date <= :end_date", {
        start_date: previous_quarter_beginning, end_date: previous_quarter_end
      }
    ).sum(:amount)
    transaction_sum > 2000
  end

  def previous_quarter_beginning
    (DateTime.current.utc - 3.months).beginning_of_quarter
  end

  def previous_quarter_end
    (DateTime.current.utc - 3.months).end_of_quarter
  end

  def reward_points(customer)
    PointsGranter.call(points: quarterly_bonus_reward_program[:quantity],
                       reward_program_id: quarterly_bonus_reward_program[:id], customer_id: customer.id)
  end

  def quarterly_bonus_reward_program
    @quarterly_bonus_reward_program ||= Constants::REWARD_PROGRAMS.find { |reward_program|
      reward_program[:name].eql?('quarterly_bonus_reward_program')
    }
  end

  def reward_already_granted?(customer)
    # checking if bonus was already granted to the customer, with customer_points_entry entry in current month.
    customer.customer_points_entries.where(reward_program_id: quarterly_bonus_reward_program[:id]).where(
      "created_at >= :start_date", { start_date: DateTime.current.utc.beginning_of_quarter }
    ).exists?
  end
end
