class TransactionSerializer < BaseModelSerializer
  attributes :id, :customer_id, :amount, :external_id, :region_type, :transaction_date, :points

  def amount
    object.amount.to_s
  end

  def region_type
    Transaction::REGION_TYPE.invert[object.region_type].to_s.upcase
  end

  def transaction_date
    AppHelperMethods.standardize_datetime(object.transaction_date)
  end

  def customer_id
    object.customer.gid
  end

  def points
    object.customer_points_entry.present? ? object.customer_points_entry.points : 0
  end
end
