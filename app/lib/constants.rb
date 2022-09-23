module Constants
  UNAUTHORIZED = "Invalid api key".freeze
  UNIQUENESS_EXCEPTION_MESSAGE = "%{model_name} with %{field_name} already exists"
  MODEL_PREFIXES = {
    "Customer" => 'cus_',
    "Transaction" => 'txn_'
  }.freeze
  INVALID_TRANSACTION_REGION_TYPE = "Invalid region type. It should either be DOMESTIC or FOREIGN".freeze
end
