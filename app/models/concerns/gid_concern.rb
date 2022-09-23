# Include in models which have gid column.
module GidConcern
  extend ActiveSupport::Concern

  included do
    before_create :generate_gid
  end

  private

  def generate_gid
    prefix = Constants::MODEL_PREFIXES[self.class.name]
    self.gid = prefix.to_s + KSUID.new.to_s
  end
end
