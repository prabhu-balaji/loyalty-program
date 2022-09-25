class CoffeeRewarderJob
  include Sidekiq::Job

  def perform(*args)
    logger.info("Running CoffeeRewarderJob :: #{DateTime.current.to_s}")
    Customer.find_each(batch_size: 200).each do |customer|
      begin
        reward_coffee(customer) if eligible_for_coffee_reward?(customer)
      rescue StandardError => exception
        logger.error("CoffeeRewarderJob::Error for customer #{customer.id} :: #{exception.message}")
      end
    end
  end

  private

  def eligible_for_coffee_reward?(customer)
    return false if reward_already_granted?(customer)

    points = customer.customer_points_entries.where(
      "created_at >= :start_date and created_at <= :end_date and transaction_id is not NULL", {
        start_date: previous_month_beginning, end_date: previous_month_end
      }
    ).sum(:points) # transaction id is not null condition is to prevent evaluating on bonus points.
    points >= 100
  end

  def previous_month_beginning
    (DateTime.current.utc - 1.month).beginning_of_month
  end

  def previous_month_end
    (DateTime.current.utc - 1.month).end_of_month
  end

  def reward_coffee(customer)
    # can be a model method
    customer_reward = customer.grant_reward(reward_id: coffee_reward.id, quantity: coffee_reward_program[:quantity],
                                            reward_program_id: coffee_reward_program[:id])
    if customer_reward.id.blank?
      logger.error("CoffeeRewarderJob::Error for customer #{customer.id}")
    end
  end

  def coffee_reward
    @coffee_reward = Reward.find_by_name(Constants::REWARDS_MAPPING[:coffee])
  end

  def coffee_reward_program
    @coffee_reward_program ||= Constants::REWARD_PROGRAMS.find { |reward_program|
      reward_program[:name].eql?('coffee_reward_program')
    }
  end

  def reward_already_granted?(customer)
    # checking if reward was already granted to the customer, with customer_reward entry in current month.
    customer.customer_rewards.where(reward_program_id: coffee_reward_program[:id], reward_id: coffee_reward.id).where(
      "created_at >= :start_date", { start_date: DateTime.current.utc.beginning_of_month }
    ).exists?
  end
end
