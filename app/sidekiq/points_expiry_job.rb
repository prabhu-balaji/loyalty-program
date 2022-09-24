class PointsExpiryJob
  include Sidekiq::Job

  def perform(*args)
    # Can set a redis key to disable redeeming points every year until this job finishes running. Since we dont have redeem points logic as of now, its okay.
    logger.info("Running PointsExpiryJob :: #{DateTime.current.to_s}")
    Customer.find_each(batch_size: 200).each do |customer|
      begin
        recalculate_points(customer)
      rescue StandardError => exception
        logger.error("PointsExpiryJob::Error for customer #{customer.id} :: #{exception.message}")
      end
    end
  end

  private

  def recalculate_points(customer)
    ActiveRecord::Base.transaction do
      customer.with_lock("LOCK IN SHARE MODE") do # Locking this prevents points being added/subtracted from else where while being updated here.
        current_year_points = customer.customer_points_entries.where("created_at >= ?",
                                                                     Time.now.beginning_of_year).sum(:points)
        customer.points = current_year_points
        customer.save!
      end
    end
  end
end
