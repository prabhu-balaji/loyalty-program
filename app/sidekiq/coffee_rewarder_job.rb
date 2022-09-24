class CoffeeRewarderJob
  include Sidekiq::Job



  def perform(*args)
    logger.info("rewarding Coffee")
    logger.info("------------------------------------------------------------------")
  end
end
