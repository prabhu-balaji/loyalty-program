module Api
  module V1
    class CustomersController < ApplicationController
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
    end
  end
end
