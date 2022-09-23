module HelperMethods
  def api_request_headers
    { 'api-key': Rails.application.credentials.api_key }
  end
end
