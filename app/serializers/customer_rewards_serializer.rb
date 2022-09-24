class CustomerRewardsSerializer < BaseModelSerializer
  self.config.adapter = :json
  attributes :id, :quantity, :expires_at, :name

  def name
    object.reward.name
  end

  def expires_at
    object.expires_at.present? ? AppHelperMethods.standardize_datetime(object.expires_at) : nil
  end
end
