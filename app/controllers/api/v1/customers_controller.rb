module Api
  module V1
    class CustomersController < ApplicationController
      rescue_from ActiveRecord::RecordNotUnique, with: :handle_uniqueness_error
      def create
        customer = Customer.new(customer_params)
        status = customer.save
        raise ApplicationBaseException.new(message: customer.errors.full_messages.first) unless status
        render json: customer, serializer: CustomerCreationSerializer
      end

      private

      def customer_params
        params.require(:customer).permit(:name, :email, :external_id, :birthday)
      end

      def handle_uniqueness_error(exception)
        render json: {
          description: format(Constants::UNIQUENESS_EXCEPTION_MESSAGE, model_name: "Customer", field_name: "external_id")
        }, status: 409
      end
    end
  end
end
