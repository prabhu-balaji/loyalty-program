class CustomerCreationSerializer < BaseModelSerializer
  attributes :id, :name, :email, :external_id, :birthday, :created_at, :updated_at
end
