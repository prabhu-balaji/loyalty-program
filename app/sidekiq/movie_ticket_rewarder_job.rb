class MovieTicketRewarderJob
  include Sidekiq::Job

  def perform(*args)
    logger.info("Running MovieTicketRewarderJob :: #{DateTime.current.to_s}")
    Customer.find_each(batch_size: 200).each do |customer|
      begin
        reward_movie_ticket(customer) if eligible_for_movie_ticket?(customer)
      rescue StandardError => exception
        logger.error("MovieTicketRewarderJob::Error for customer #{customer.id} :: #{exception.message}")
      end
    end
  end

  private

  def reward_movie_ticket(customer)
    customer_reward = customer.grant_reward(reward_id: movie_reward.id, quantity: 1,
                                            reward_program_id: movie_reward_program[:id])
    logger.error("MovieTicketRewarderJob::Error for customer #{customer.id}") if customer_reward.id.blank?
  end

  def eligible_for_movie_ticket?(customer)
    !reward_already_granted?(customer) &&
      !first_txn_beyond_last_60_days?(customer) &&
      customer.transactions.sum(:amount) > 1000
  end

  def movie_reward
    @coffee_reward = Reward.find_by_name('movie_ticket')
  end

  def first_txn_beyond_last_60_days?(customer)
    customer.transactions.exists? &&
      customer.transactions.order(:id).first.created_at < DateTime.current.utc.beginning_of_day - 60.days # If customer's first transaction is within last 60 days range.
  end

  def movie_reward_program
    @movie_reward_program ||= Constants::REWARD_PROGRAMS.find { |reward_program|
      reward_program[:name].eql?('movie_reward_program')
    }
  end

  def reward_already_granted?(customer)
    customer.customer_rewards.where(reward_program_id: movie_reward_program[:id], reward_id: movie_reward.id).exists?
  end
end
