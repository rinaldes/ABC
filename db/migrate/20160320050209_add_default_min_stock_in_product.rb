class AddDefaultMinStockInProduct < ActiveRecord::Migration
  def change
    add_column :product_sizes, :default_min_stock, :integer
  end
end
