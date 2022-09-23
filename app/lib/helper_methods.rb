module HelperMethods
  class << self
    def standardize_datetime(datetime)
      # Convert datetime to iso8601 with timezone info
      datetime.to_time.iso8601
    end
  end
end