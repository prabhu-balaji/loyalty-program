class Unauthorized < ApplicationExceptionBase
  def initialize(message: '')
    @code = 401
    @message = message.blank? ? Constants::UNAUTHORIZED : message
  end
end