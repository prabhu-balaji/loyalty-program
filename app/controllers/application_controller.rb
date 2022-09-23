class ApplicationController < ActionController::API
  before_action :authenticate_service
  include Authenticable
  include ApiRescuable
end
