FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    birthday { Faker::Date.birthday.to_s }
    external_id { KSUID.new.to_s }
  end
end