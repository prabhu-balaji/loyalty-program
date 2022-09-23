module Api
  module V1
    class TransactionsController < ApplicationController
      before_action :validate_required_params, only: [:create]
      before_action :prepare_params, only: [:create]

      rescue_from ActiveRecord::RecordNotUnique do
        handle_uniqueness_error(model_name: 'Transaction', field_name: 'external_id')
      end

      def create
        transaction = Transaction.new(transaction_params)
        status = transaction.save
        raise ApplicationBaseException.new(message: transaction.errors.full_messages.first) unless status

        render json: transaction, serializer: TransactionCreationSerializer, status: :created
      end

      def show
        transaction = Transaction.find_by_gid(params[:id])
        raise ObjectNotFound.new(object_name: 'Transaction') if transaction.blank?

        render json: transaction
      end

      private

      def prepare_params
        if transaction_params[:region_type].present?
          transaction_params[:region_type] = Transaction::REGION_TYPE[transaction_params[:region_type].downcase.to_sym]
          raise ApplicationBaseException.new(message: Constants::INVALID_TRANSACTION_REGION_TYPE) if transaction_params[:region_type].blank?
        end
        transaction_params[:amount] = transaction_params[:amount].to_f if transaction_params[:amount].present?
      end

      def transaction_params
        @transaction_params ||= params[:transaction].permit(:external_id, :amount, :external_id, :transaction_date,
                                                            :region_type)
      end

      def validate_required_params
        params.require(:transaction).require(:amount)
      end
    end
  end
end
