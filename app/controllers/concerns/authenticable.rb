module Authenticable
  extend ActiveSupport::Concern

  def authenticate_service
    api_key = Rails.application.credentials.api_key
    api_key_from_headers = request.headers['api-key']
    is_valid_api_key = api_key_from_headers.present? && ActiveSupport::SecurityUtils.secure_compare(api_key, api_key_from_headers)
    raise Unauthorized unless is_valid_api_key
  end
end