class AddTierIdToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :tier_id, :integer, limit: 1
  end
end
