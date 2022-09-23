class Unauthorized < ApplicationBaseException
  def initialize(message: '')
    @status_code = 401
    @message = message.blank? ? Constants::UNAUTHORIZED : message
  end
end