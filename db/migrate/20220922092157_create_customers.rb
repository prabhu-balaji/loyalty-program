class CreateCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers do |t|
      t.string :gid, limit: 40, null: false
      t.string :name
      t.string :email
      t.string :external_id
      t.date :birthday

      t.timestamps
    end
    add_index :customers, :gid
    add_index :customers, :external_id, unique: true
  end
end
