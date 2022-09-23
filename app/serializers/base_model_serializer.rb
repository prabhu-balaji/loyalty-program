### Base model serializer from which other model serializers can inherit to overwrite below methods to standardize the format ####
class BaseModelSerializer < ActiveModel::Serializer
  def id
    object.gid.to_s
  end

  def created_at
    AppHelperMethods.standardize_datetime(object.created_at)
  end

  def updated_at
    AppHelperMethods.standardize_datetime(object.updated_at)
  end
end
