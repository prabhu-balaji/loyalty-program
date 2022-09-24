class AddGidToCustomerRewards < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_rewards, :gid, :string, limit: 40, null: false
    add_index :customer_rewards, :gid
  end
end
