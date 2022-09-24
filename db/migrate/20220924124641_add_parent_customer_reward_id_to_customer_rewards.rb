class AddParentCustomerRewardIdToCustomerRewards < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_rewards, :parent_customer_reward_id, :integer, :limit => 8
  end
end
