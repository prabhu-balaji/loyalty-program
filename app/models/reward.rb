class Reward < ApplicationRecord
  include GidConcern

  validates_presence_of :name
end
