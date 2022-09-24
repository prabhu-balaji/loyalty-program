class CreateCustomerRewards < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_rewards do |t|
      t.integer :customer_id, :limit => 8, null: false
      t.integer :reward_id, :limit => 8, null: false
      t.integer :reward_program_id, :limit => 8
      t.decimal :quantity
      t.integer :status, limit: 1
      t.datetime :expires_at

      t.timestamps
    end
    add_index :customer_rewards, :customer_id
  end
end
