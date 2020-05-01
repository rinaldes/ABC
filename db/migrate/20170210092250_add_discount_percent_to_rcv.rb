class AddDiscountPercentToRcv < ActiveRecord::Migration
  def change
    add_column :receivings, :discount_percent1, :float
    add_column :receivings, :discount_percent2, :float
    add_column :receivings, :discount_percent3, :float
    add_column :receivings, :discount_percent4, :float
  end
end
