module Api
  module V1
    class CustomersController < ApplicationController
      rescue_from ActiveRecord::RecordNotUnique do
        handle_uniqueness_error(model_name: 'Customer', field_name: 'external_id')
      end
      def create
        customer = Customer.new(customer_params)
        status = customer.save
        raise ApplicationBaseException.new(message: customer.errors.full_messages.first) unless status

        render json: customer, serializer: CustomerCreationSerializer, status: :created
      end

      def show
        customer = Customer.find_by_gid(params[:id])
        raise ObjectNotFound.new(object_name: 'Customer') if customer.blank?

        render json: customer
      end

      private

      def customer_params
        params.require(:customer).permit(:name, :email, :external_id, :birthday)
      end
    end
  end
end
