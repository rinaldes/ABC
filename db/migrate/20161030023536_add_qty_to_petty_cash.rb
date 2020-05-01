class AddQtyToPettyCash < ActiveRecord::Migration
  def change
    add_column :cash_outs, :qty, :float
    add_column :cash_outs, :unit, :string
    add_column :cash_outs, :price_per_unit, :float
  end
end
