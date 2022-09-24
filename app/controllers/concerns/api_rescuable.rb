module ApiRescuable
  extend ActiveSupport::Concern

  included do
    rescue_from ApplicationBaseException, with: :handle_exception
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  end

  private

  def handle_parameter_missing(exception)
    render json: { description: exception.message }, status: 400
  end

  def handle_exception(exception)
    render json: exception.serializable_hash, status: exception.status_code
  end

  def handle_uniqueness_error(model_name:, field_name:)
    render json: {
      description: format(Constants::UNIQUENESS_EXCEPTION_MESSAGE, model_name: model_name, field_name: field_name)
    }, status: 409
  end

  def handle_record_not_found(exception)
    render json: {
      description: "#{exception.model} not found"
    }, status: 404
  end
end
