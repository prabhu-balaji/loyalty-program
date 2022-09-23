module Constants
  UNAUTHORIZED = "Invalid api key".freeze
  UNIQUENESS_EXCEPTION_MESSAGE = "%{model_name} with %{field_name} already exists"
  MODEL_PREFIXES = {
    "Customer" => 'cus_',
    "Transaction" => 'txn_'
  }.freeze
  INVALID_TRANSACTION_REGION_TYPE = "Invalid region type. It should either be DOMESTIC or FOREIGN".freeze
  PER_DOLLARS_TO_ADD_POINTS = 100.freeze
  POINTS_MULTIPLIER = 10
  FOREIGN_ADDITIONAL_MULTIPLIER = 2
end
