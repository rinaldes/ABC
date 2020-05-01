class AddSellPriceToProductMutation < ActiveRecord::Migration
  def change
    add_column :product_mutations, :sell_price, :float
  end
end
