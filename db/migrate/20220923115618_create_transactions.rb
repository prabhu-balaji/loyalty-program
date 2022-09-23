class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.string :gid, limit: 40, null: false
      t.string :external_id
      t.integer :region_type, limit: 1
      t.decimal :amount, precision: 20, scale: 5, null: false
      t.datetime :transaction_date
      t.integer :customer_id, :limit => 8, null: false
      t.timestamps
    end
    add_index :transactions, :gid
    add_index :transactions, :external_id, unique: true
  end
end
