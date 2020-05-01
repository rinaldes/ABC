class AddAmtHoToPtRcv < ActiveRecord::Migration
  def change
    add_column :pr_transfer_products, :amount_ho, :float
    add_column :pr_transfer_products, :value_ho, :float
  end
end
