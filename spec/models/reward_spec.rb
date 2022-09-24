require 'rails_helper'

RSpec.describe Reward, type: :model do
  it "should create a reward record with fields" do
    expect(Reward.new.valid?).to be false
    name = Faker::Name.name
    reward = Reward.create(name: name)
    expect(reward.id.present?).to be true

    reward.destroy
    expect(Reward.find_by_id(reward.id)).to be nil
  end
end
