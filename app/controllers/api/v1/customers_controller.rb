module Api
  module V1
    class CustomersController < ApplicationController
      before_action :validate_reward_claim_params, only: [:claim_reward]

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

      def claim_reward
        customer = Customer.find_by_gid(reward_claim_params[:id])
        raise ObjectNotFound.new(object_name: 'Customer') if customer.blank?

        customer_reward = customer.customer_rewards.where(gid: reward_claim_params[:customer_reward_id],
                                                          status: CustomerReward::STATUS_MAPPING[:active]).first
        raise ObjectNotFound.new(object_name: 'Customer Reward') if customer_reward.blank?

        validate_reward_criteria(customer_reward)
        update_status_to_claimed(customer_reward: customer_reward, quantity: reward_claim_params[:quantity])
        render json: { success: true }
      end

      private

      def customer_params
        params.require(:customer).permit(:name, :email, :external_id, :birthday)
      end

      def validate_reward_claim_params
        reward_claim_params.require([:quantity, :customer_reward_id, :id])
        reward_claim_params[:quantity] = reward_claim_params[:quantity]
        raise ApplicationBaseException.new(message: Constants::INVALID_QUANTITY) unless reward_claim_params[:quantity] > 0
      end

      def reward_claim_params
        @reward_claim_params ||= params.permit(:customer_reward_id, :quantity, :id)
      end

      def validate_reward_criteria(customer_reward) # TODO: can refactor and move to model or service.
        raise ApplicationBaseException.new(message: Constants::REWARD_EXPIRED_ERROR) if customer_reward.expired?
        raise ApplicationBaseException.new(message: Constants::INSUFFICIENT_QUANTITY) if params[:quantity] > customer_reward.quantity
      end

      def update_status_to_claimed(customer_reward:, quantity:)
        ActiveRecord::Base.transaction do
          CustomerReward.update_counters(customer_reward.id, quantity: -quantity)
          CustomerReward.create!(reward_id: customer_reward.reward_id, customer_id: customer_reward.customer_id, parent_customer_reward_id: customer_reward.id,
                                 reward_program_id: customer_reward.reward_program_id, quantity: quantity, status: CustomerReward::STATUS_MAPPING[:redeemed])
        end
      end
    end
  end
end
