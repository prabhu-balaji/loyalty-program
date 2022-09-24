class CreateRewards < ActiveRecord::Migration[6.0]
  def change
    create_table :rewards do |t|
      t.string :gid, limit: 40, null: false
      t.string :name, null: false
      t.timestamps
    end
    add_index :rewards, :gid
  end
end
