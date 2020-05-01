class StockHoInPtRcv < ActiveRecord::Migration
  def change
    add_column :pr_transfer_products, :stock_ho, :integer
  end
end
