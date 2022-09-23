class ApplicationBaseException < StandardError
  attr_accessor :status_code, :message

  def initialize(status_code: 400, message: '')
    @status_code = status_code
    @message = message
  end

  def serializable_hash
    {
      'description': message
    }
  end
end
