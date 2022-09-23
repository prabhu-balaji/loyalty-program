class TransactionSerializer < BaseModelSerializer
  attributes :id, :external_id, :amount, :region_type, :transaction_date

  def amount
    object.amount.to_s
  end

  def region_type
    Transaction::REGION_TYPE.invert[object.region_type].to_s.upcase
  end

  def transaction_date
    AppHelperMethods.standardize_datetime(object.transaction_date)
  end
end
