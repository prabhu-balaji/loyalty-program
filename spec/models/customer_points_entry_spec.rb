require 'rails_helper'

RSpec.describe CustomerPointsEntry, type: :model do
  before(:all) do
    @customer = FactoryBot.create(:customer)
  end

  it "should throw error when customer_id not present" do
    customer_points_entry = CustomerPointsEntry.new
    expect(customer_points_entry.valid?).to be false
    expect(customer_points_entry.errors.full_messages.first).to eql("Customer must exist")
  end

  it "should throw error when points not present" do
    customer_points_entry = CustomerPointsEntry.new(customer_id: @customer.id)
    expect(customer_points_entry.valid?).to be false
    expect(customer_points_entry.errors.full_messages.first).to eql("Points can't be blank")
  end

  it "should create record with txn id" do
    transaction = FactoryBot.create(:transaction)
    points = 20
    customer_points_entry = CustomerPointsEntry.create(customer_id: transaction.customer_id, points: points,
                                                       transaction_id: transaction.id)
    expect(customer_points_entry.id.present?).to eql(true)
    customer_points_entry.reload
    expect(customer_points_entry.points).to eql(points)
    expect(customer_points_entry.customer).to eql(transaction.customer)
    expect(customer_points_entry.customer_transaction).to eql(transaction)
  end

  it "should create record without txn id" do
    points = 20
    customer_points_entry = CustomerPointsEntry.create(customer_id: @customer.id, points: points)
    expect(customer_points_entry.id.present?).to eql(true)
    customer_points_entry.reload
    expect(customer_points_entry.points).to eql(points)
    expect(customer_points_entry.customer).to eql(@customer)
    expect(customer_points_entry.customer_transaction).to be nil
  end
end
