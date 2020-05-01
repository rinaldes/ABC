class AddDistributedQtyToReceiving < ActiveRecord::Migration
  def change
    add_column :receivings, :distributed_qty, :integer, default: 0
  end
end
