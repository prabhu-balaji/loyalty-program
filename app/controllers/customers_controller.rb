class CustomersController < ApplicationController

  def create
    customer = Customer.new(customer_params)
    customer.save
    render json: customer, serializer: CustomerCreationSerializer
  end

  private

  def customer_params
    params.require(:customer).permit(:name, :email, :external_id, :birthday)
  end
end
