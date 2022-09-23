class CreateCustomerPointsEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_points_entries do |t|
      t.integer :customer_id, :limit => 8, null: false
      t.integer :transaction_id, :limit => 8
      t.decimal :points, precision: 20, null: false
      t.integer :reward_program_id, :limit => 8
      t.timestamps
    end
    add_index :customer_points_entries, :transaction_id
    add_index :customer_points_entries, :customer_id
  end
end
