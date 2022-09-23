class ObjectNotFound < ApplicationBaseException
  attr_accessor :object_name

  def initialize(object_name: '')
    @object_name = object_name
  end

  def serializable_hash
    {
      'description': "#{object_name} not found"
    }
  end

  def status_code
    404
  end
end