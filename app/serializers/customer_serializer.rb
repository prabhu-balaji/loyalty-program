class CustomerSerializer < BaseModelSerializer
  attributes :id, :name, :email, :external_id, :birthday, :created_at, :points, :tier

  def tier
    Constants::CUSTOMER_TIERS.invert[object.tier_id].to_s.upcase
  end
end
