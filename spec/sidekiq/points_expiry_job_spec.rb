require 'rails_helper'
RSpec.describe PointsExpiryJob, type: :job do
  before(:all) do
    Customer.delete_all # To reduce time taken to execute
  end

  after(:all) do
    Customer.delete_all
  end

  it "should test PointsExpiryJob for various scenarios" do
    assert Sidekiq::Cron::Job.find("new_year_points_expirer").cron == "0 0 1 1 *"
    customer_1 = FactoryBot.create(:customer)
    customer_2 = FactoryBot.create(:customer)

    2.times { PointsGranter.call(points: 100, customer_id: customer_1.id) }
    PointsGranter.call(points: 100, customer_id: customer_2.id)

    expect(customer_1.reload.points).to eql(200)
    expect(customer_2.reload.points).to eql(100)

    # Updating customer_2 points entry to last year
    expect(customer_2.customer_points_entries.to_a.size).to eql(1)
    customer_2_points_entry = customer_2.customer_points_entries.first
    expect(customer_2_points_entry.update(created_at: DateTime.current.utc - 1.year)).to be true

    PointsExpiryJob.new.perform
    expect(customer_1.reload.points).to eql(200)
    expect(customer_2.reload.points).to eql(0)
  end
end

Sidekiq::Cron::Job
