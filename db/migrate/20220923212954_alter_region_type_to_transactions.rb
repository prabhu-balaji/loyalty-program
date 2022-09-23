class AlterRegionTypeToTransactions < ActiveRecord::Migration[6.0]
  def change
    change_column :transactions, :region_type, :integer, limit: 1, default: Transaction::REGION_TYPE[:domestic]
  end
end
