class Customer < ApplicationRecord
  include GidConcern

  has_many :transactions

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
