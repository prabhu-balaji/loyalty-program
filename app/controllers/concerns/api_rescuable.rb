module ApiRescuable
  extend ActiveSupport::Concern

  included do
    rescue_from ApplicationBaseException, with: :handle_exception
  end

  private

  def handle_exception(exception)
    render json: exception.serializable_hash, status: exception.status_code
  end
end
