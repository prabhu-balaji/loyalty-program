module Constants
  UNAUTHORIZED = "Invalid api key".freeze
  UNIQUENESS_EXCEPTION_MESSAGE = "%{model_name} with %{field_name} already exists"
  MODEL_PREFIXES = {
    "Customer" => 'cus_',
    "Transaction" => 'txn_'
  }.freeze
end
