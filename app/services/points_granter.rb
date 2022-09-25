class PointsGranter < ApplicationService
  def initialize(customer_id:, points:, transaction_id: nil, reward_program_id: nil)
    @customer_id = customer_id
    @points = points
    @transaction_id = transaction_id
    @reward_program_id = reward_program_id
  end

  def call
    ActiveRecord::Base.transaction do
      CustomerPointsEntry.create!(customer_id: @customer_id, points: @points, transaction_id: @transaction_id,
                                  reward_program_id: @reward_program_id)
      Customer.update_counters(@customer_id, points: @points)
    end
  end
end
