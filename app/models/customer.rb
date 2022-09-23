class Customer < ApplicationRecord
  include GidConcern

  has_many :transactions
  has_many :customer_points_entries

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
