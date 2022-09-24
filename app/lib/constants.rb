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
      name: 'coffee_reward_per_calendar_month',
      description: 'If the end user accumulates 100 points in one calendar month they are given a Free Coffee reward'
    }
  ].freeze # TODO: Move to db. keeping this hardcoded for now. Ideally clients should be able to create reward programs by themselves.

  REWARD_EXPIRED_ERROR = "Reward has expired."
  INSUFFICIENT_QUANTITY = "Insufficient quantity"
  REWARD_ALREADY_CLAIMED = "Reward has already been claimed"
  INVALID_QUANTITY = "Invalid quantity"

end
