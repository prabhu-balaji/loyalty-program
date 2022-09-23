class CustomerSerializer < BaseModelSerializer
  attributes :id, :name, :email, :external_id, :birthday, :created_at, :points
end
