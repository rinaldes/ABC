class AddSyncAtToSales < ActiveRecord::Migration
  def change
    add_column :member_balance_mutations, :sync_at, :datetime
    add_column :member_point_mutations, :sync_at, :datetime
  end
end
