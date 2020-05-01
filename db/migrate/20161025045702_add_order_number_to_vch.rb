class AddOrderNumberToVch < ActiveRecord::Migration
  def change
    add_column :vouchers, :order_number, :string
    add_column :vouchers, :is_available, :boolean
  end
end
