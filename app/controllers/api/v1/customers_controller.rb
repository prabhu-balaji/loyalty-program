module Api
  module V1
    class CustomersController < ApplicationController
      before_action :validate_reward_claim_params, only: [:claim_reward]

      rescue_from ActiveRecord::RecordNotUnique do
        handle_uniqueness_error(model_name: 'Customer', field_name: 'external_id')
      end # Random comment 2
      def create # Random comment 2
        customer = Customer.new(customer_params)
        status = customer.save # random comment 3
        raise ApplicationBaseException.new(message: customer.errors.full_messages.first) unless status

        render json: customer, serializer: CustomerCreationSerializer, status: :created
      end

      def show
        customer = Customer.find_by_gid!(params[:id])
        render json: customer
      end

      def claim_reward
        RewardClaimer.call(
          customer_id: reward_claim_params[:id],
          customer_reward_id: reward_claim_params[:customer_reward_id],
          quantity: reward_claim_params[:quantity]
        )
        render json: { success: true }
      end

      def customer_rewards
        customer = Customer.find_by_gid!(params[:id])
        available_customer_rewards = customer.customer_rewards.available_rewards.includes(:reward).to_a
        render json: available_customer_rewards,
               root: "customer_rewards",
               each_serializer: CustomerRewardsSerializer,
               adapter: :json
      end

      private

      def customer_params
        params.require(:customer).permit(:name, :email, :external_id, :birthday)
      end

      def validate_reward_claim_params
        reward_claim_params.require([:quantity, :customer_reward_id, :id])
        raise ApplicationBaseException.new(message: Constants::INVALID_QUANTITY) unless reward_claim_params[:quantity] > 0
      end

      def reward_claim_params
        @reward_claim_params ||= params.permit(:customer_reward_id, :quantity, :id)
      end
    end
  end
end
