class BirthdayMonthRewardJob
  include Sidekiq::Job

  def perform(*args)
    logger.info("Running BirthdayMonthRewardJob :: #{DateTime.current.to_s}")
    Customer.where('EXTRACT(MONTH FROM birthday) = ?', current_month).find_each(batch_size: 200).each do |customer|
      begin
        reward_coffee(customer) unless reward_already_granted?(customer)
      rescue StandardError => exception
        logger.error("BirthdayMonthRewardJob::Error for customer #{customer.id} :: #{exception.message}")
      end
    end
  end

  private

  def current_month
    DateTime.current.utc.month
  end

  def reward_coffee(customer)
    expires_at = DateTime.current.utc.end_of_month # Birthday reward typically expires end of birthday month.
    customer_reward = customer.grant_reward(reward_id: coffee_reward.id, quantity: 1,
                                            reward_program_id: birthday_reward_program[:id], expires_at: expires_at)
    logger.error("BirthdayMonthRewardJob::Error for customer #{customer.id}") if customer_reward.id.blank?
  end

  def coffee_reward
    @coffee_reward = Reward.find_by_name(Constants::REWARDS_MAPPING[:coffee])
  end

  def previous_month_beginning
    (DateTime.current.utc - 1.month).beginning_of_month
  end

  def previous_month_end
    (DateTime.current.utc - 1.month).end_of_month
  end

  def birthday_reward_program
    @birthday_reward_program ||= Constants::REWARD_PROGRAMS.find { |reward_program|
      reward_program[:name].eql?('birthday_reward_program')
    }
  end

  def reward_already_granted?(customer)
    customer.customer_rewards.where(reward_program_id: birthday_reward_program[:id], reward_id: coffee_reward.id)
            .where("created_at >= ?", DateTime.current.utc.beginning_of_month).exists?
  end
end
