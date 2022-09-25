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

  describe 'should test lounge access reward' do
    it "should not grant lounge access reward to standard customer" do
      customer = Customer.create(name: Faker::Name.name)
      expect(customer.tier_id).to eql(Constants::CUSTOMER_TIERS[:standard])
      expect(customer.customer_rewards.to_a.size).to eql(0)
    end

    it "should grant lounge access reward when upgrading from standard customer to gold" do
      customer = Customer.create(name: Faker::Name.name)
      expect(customer.tier_id).to eql(Constants::CUSTOMER_TIERS[:standard])
      expect(customer.customer_rewards.to_a.size).to eql(0)

      customer.tier_id = Constants::CUSTOMER_TIERS[:gold]
      customer.save
      customer.reload
      expect(customer.tier_id).to eql(Constants::CUSTOMER_TIERS[:gold])
      expect(customer.customer_rewards.to_a.size).to eql(1)
      customer_reward = customer.customer_rewards.first
      expect(customer_reward.reward_id).to eql(lounge_access_reward.id)
      expect(customer_reward.quantity).to eql(4)
      expect(customer_reward.reward_program_id).to eql(lounge_access_reward_program[:id])
      expect(customer_reward.status).to eql(CustomerReward::STATUS[:active])

      # downgrading to standard and upgrading to gold should not grant again in same calendar year.
      customer.tier_id = Constants::CUSTOMER_TIERS[:standard]
      customer.save
      customer.tier_id = Constants::CUSTOMER_TIERS[:gold]
      customer.save
      customer.reload
      expect(customer.tier_id).to eql(Constants::CUSTOMER_TIERS[:gold])
      expect(customer.customer_rewards.to_a.size).to eql(1)
      customer_reward = customer.customer_rewards.first
      expect(customer_reward.reward_id).to eql(lounge_access_reward.id)
      expect(customer_reward.quantity).to eql(4)
      expect(customer_reward.reward_program_id).to eql(lounge_access_reward_program[:id])
      expect(customer_reward.status).to eql(CustomerReward::STATUS[:active])

      # upgrading from gold to platinum should not grant reward
      customer.tier_id = Constants::CUSTOMER_TIERS[:platinum]
      customer.save
      customer.reload
      expect(customer.tier_id).to eql(Constants::CUSTOMER_TIERS[:platinum])
      expect(customer.customer_rewards.to_a.size).to eql(1)
      customer_reward = customer.customer_rewards.first
      expect(customer_reward.reward_id).to eql(lounge_access_reward.id)
      expect(customer_reward.quantity).to eql(4)
      expect(customer_reward.reward_program_id).to eql(lounge_access_reward_program[:id])
      expect(customer_reward.status).to eql(CustomerReward::STATUS[:active])
    end

    it "should grant lounge access reward when upgrading from standard customer to platinum" do
      customer = Customer.create(name: Faker::Name.name)
      expect(customer.tier_id).to eql(Constants::CUSTOMER_TIERS[:standard])
      expect(customer.customer_rewards.to_a.size).to eql(0)

      customer.tier_id = Constants::CUSTOMER_TIERS[:platinum]
      customer.save
      customer.reload
      expect(customer.tier_id).to eql(Constants::CUSTOMER_TIERS[:platinum])
      expect(customer.customer_rewards.to_a.size).to eql(1)
      customer_reward = customer.customer_rewards.first
      expect(customer_reward.reward_id).to eql(lounge_access_reward.id)
      expect(customer_reward.quantity).to eql(4)
      expect(customer_reward.reward_program_id).to eql(lounge_access_reward_program[:id])
      expect(customer_reward.status).to eql(CustomerReward::STATUS[:active])
    end
  end
end
