module Constants
  UNAUTHORIZED = "Invalid api key".freeze
  UNIQUENESS_EXCEPTION_MESSAGE = "%{model_name} with %{field_name} already exists"
  MODEL_PREFIXES = {
    "Customer" => 'cus_',
    "Transaction" => 'txn_',
    "CustomerReward" => 'cus_rew_'
  }.freeze
  INVALID_TRANSACTION_REGION_TYPE = "Invalid region type. It should either be DOMESTIC or FOREIGN".freeze
  PER_DOLLARS_TO_ADD_POINTS = 100.freeze
  POINTS_MULTIPLIER = 10
  FOREIGN_ADDITIONAL_MULTIPLIER = 2

  REWARD_PROGRAMS = [
    {
      id: 1,
      name: 'coffee_reward_program',
      description: 'If the end user accumulates 100 points in one calendar month they are given a Free Coffee reward'
    },
    {
      id: 2,
      name: 'movie_reward_program',
      description: 'A Free Movie Tickets reward is given to new users when their spending is > $1000 within 60 days of their first transaction'
    },
    {
      id: 3,
      name: 'cash_rebate_program',
      description: 'A 5% Cash Rebate reward is given to all users who have 10 or more transactions that have an amount > $100'
    },
    {
      id: 4,
      name: 'birthday_reward_program',
      description: 'A Free Coffee reward is given to all users during their birthday month'
    }
  ].freeze # TODO: Move to db. keeping this hardcoded for now. Ideally clients should be able to create reward programs & configure rules by themselves.

  REWARDS_MAPPING = {
    coffee: "Coffee",
    movie_ticket: "Movie Ticket",
    cash_rebate: "5% cash rebate"
  }.freeze

  REWARD_EXPIRED_ERROR = "Reward has expired."
  INSUFFICIENT_QUANTITY = "Insufficient quantity"
  INVALID_QUANTITY = "Invalid quantity"
end
