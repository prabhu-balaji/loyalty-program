class AddPointsToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :points, :decimal, precision: 20, :default => 0
  end
end
