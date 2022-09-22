class Customer < ApplicationRecord
  include ActiveRecord::KSUID[:gid, prefix: 'cus_']

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
