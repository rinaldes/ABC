class AddRthoAndTrfToDsi < ActiveRecord::Migration
  def change
    add_column :daily_sales_inventories, :rtho_qty, :float
    add_column :daily_sales_inventories, :rtho_price, :float
    add_column :daily_sales_inventories, :trf_qty, :float
    add_column :daily_sales_inventories, :trf_price, :float
  end
end
