class Customer < ApplicationRecord
  include GidConcern

  has_many :transactions
  has_many :customer_points_entries
  has_many :customer_rewards

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  before_validation :set_tier_id
  after_commit :grant_lounge_access_reward, if: :grant_lounge_access_reward?

  def grant_reward(reward_id:, quantity:, reward_program_id: nil, expires_at: nil)
    self.customer_rewards.create(
      reward_id: reward_id,
      reward_program_id: reward_program_id,
      quantity: quantity,
      status: CustomerReward::STATUS_MAPPING[:active],
      expires_at: expires_at
    )
  end

  def grant_points(points:, transaction_id: nil, reward_program_id: nil)
    PointsGranter.call(points: points, transaction_id: transaction_id, reward_program_id: reward_program_id,
                       customer_id: self.id)
  end

  private

  def set_tier_id
    self.tier_id = Constants::CUSTOMER_TIERS[:standard] if self.tier_id.blank?
  end

  def grant_lounge_access_reward
    lounge_access_reward = Reward.find_by_name(Constants::REWARDS_MAPPING[:lounge_access])
    reward_program = Constants::REWARD_PROGRAMS.find { |reward_program|
      reward_program[:name].eql?('lounge_access_reward_program')
    }
    self.grant_reward(reward_id: lounge_access_reward.id, quantity: 4, reward_program_id: reward_program[:id]) # Not putting expiry for now.
  end

  def grant_lounge_access_reward?
    tier_id_key_changed = self.previous_changes.key?(:tier_id) && self.tier_id.in?(Constants::ELIGIBLE_TIERS_FOR_LOUNGE) &&
                          !self.previous_changes[:tier_id].first.in?(Constants::ELIGIBLE_TIERS_FOR_LOUNGE)
    return unless tier_id_key_changed

    lounge_access_reward = Reward.find_by_name(Constants::REWARDS_MAPPING[:lounge_access])
    lounge_access_reward_program = Constants::REWARD_PROGRAMS.find { |reward_program|
      reward_program[:name].eql?('lounge_access_reward_program')
    }
    tier_id_key_changed && !reward_already_granted?(reward_id: lounge_access_reward.id,
                                                    reward_program_id: lounge_access_reward_program[:id], start_date: DateTime.current.utc.beginning_of_year, end_date: DateTime.current.utc.end_of_year)
  end

  def reward_already_granted?(reward_id:, start_date:, end_date:, reward_program_id: nil)
    self.customer_rewards.where(reward_program_id: reward_program_id, reward_id: reward_id).where(
      "created_at >= :start_date and created_at <= :end_date", { start_date: start_date, end_date: end_date }
    ).exists?
  end
end
