class CustomerPointsEntry < ApplicationRecord
  belongs_to :customer
  belongs_to :customer_transaction, foreign_key: "transaction_id", class_name: "Transaction", optional: true
  # Since rails does not allow belongs_to :transaction. TODO: change transaction to customer_transaction in all places.
  validates_presence_of :points
end
