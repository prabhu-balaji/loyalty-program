class CashRebateJob
  include Sidekiq::Job

  MINIMUM_TRANSACTION_AMOUNT = 100.freeze
  MINIMUM_TRANSACTION_COUNT = 10.freeze

  def perform(*args)
    logger.info("Running CashRebateJob :: #{DateTime.current.to_s}")
    Customer.find_each(batch_size: 200).each do |customer|
      begin
        reward_cash_rebate(customer) if eligible_for_cash_rebate?(customer)
      rescue StandardError => exception
        logger.error("CashRebateJob::Error for customer #{customer.id} :: #{exception.message}")
      end
    end
  end

  private

  def reward_cash_rebate(customer)
    customer_reward = customer.grant_reward(reward_id: cash_rebate_reward.id, quantity: 1,
                                            reward_program_id: cash_rebate_program[:id])
    logger.error("CashRebateJob::Error for customer #{customer.id}") if customer_reward.id.blank?
  end

  def eligible_for_cash_rebate?(customer)
    # 10 or more transactions that have an amount > $100 in last month
    return false if reward_already_granted?(customer)

    customer.transactions.where("transaction_date >= :start_date and transaction_date <= :end_date and amount > #{MINIMUM_TRANSACTION_AMOUNT}", {
                                  start_date: previous_month_beginning, end_date: previous_month_end
                                }).count >= MINIMUM_TRANSACTION_COUNT
  end

  def cash_rebate_reward
    @coffee_reward = Reward.find_by_name(Constants::REWARDS_MAPPING[:cash_rebate])
  end

  def previous_month_beginning
    (DateTime.current.utc - 1.month).beginning_of_month
  end

  def previous_month_end
    (DateTime.current.utc - 1.month).end_of_month
  end

  def cash_rebate_program
    @cash_rebate_program ||= Constants::REWARD_PROGRAMS.find { |reward_program|
      reward_program[:name].eql?('cash_rebate_program')
    }
  end

  def reward_already_granted?(customer)
    customer.customer_rewards.where(reward_program_id: cash_rebate_program[:id], reward_id: cash_rebate_reward.id)
            .where("created_at >= ?", DateTime.current.utc.beginning_of_month).exists?
  end
end
