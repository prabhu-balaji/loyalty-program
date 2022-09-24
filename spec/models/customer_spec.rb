require 'rails_helper'

RSpec.describe Customer, type: :model do
  it "should create a customer with fields" do
    external_id = KSUID.new.to_s
    name = Faker::Name.name
    email = Faker::Internet.email
    birthday = Faker::Date.birthday.to_s
    customer = Customer.create(name: name, email: email, birthday: birthday, external_id: external_id)
    expect(customer.id.present?).to be true
    expect(customer.gid.starts_with?("cus_")).to be true
    expect(customer.name).to eql(name)
    expect(customer.external_id).to eql(external_id)
    expect(customer.email).to eql(email)
    expect(customer.birthday.to_s).to eql(birthday)
    expect(customer.created_at.present?).to be true
    expect(customer.updated_at.present?).to be true
    expect(customer.points).to eql(0)
    expect(customer.tier_id).to eql(Constants::CUSTOMER_TIERS[:standard])

    # update
    customer.points = 20
    customer.save
    expect(customer.reload.points).to eql(20)
  end

  it "should create a customer with just external_id and then perform update on a different field" do
    external_id = KSUID.new.to_s
    customer = Customer.create(external_id: external_id)
    expect(customer.id.present?).to be true
    expect(customer.gid.starts_with?("cus_")).to be true
    expect(customer.external_id).to eql(external_id)

    customer.name = "Random"
    customer.save
    customer.reload
    expect(customer.name).to eql("Random")
  end

  it "should throw error a customer with invalid email" do
    customer = Customer.new(email: "abc")
    expect(customer.valid?).to be false
    expect(customer.errors.full_messages).to eql(["Email is invalid"])
    expect(customer.save).to be false
  end

  it "should throw error when trying to create a customer with external id already present" do
    external_id = KSUID.new.to_s
    customer = Customer.new(external_id: external_id)
    customer.save
    expect(customer.id.present?).to be true
    duplicate_customer = Customer.new(external_id: external_id)
    expect { duplicate_customer.save }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "should destroy a customer do" do
    customer = FactoryBot.create(:customer)
    customer.destroy
    expect(Customer.find_by_id(customer.id)).to be nil
  end
end
