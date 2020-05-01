class AddColumnIsSpecialDiscount < ActiveRecord::Migration
  def change
    add_column :sales_details, :is_special_discount, :boolean
    add_column :sales, :special_discount, :float
  end
end
