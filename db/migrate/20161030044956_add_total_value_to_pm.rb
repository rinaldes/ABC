class AddTotalValueToPm < ActiveRecord::Migration
  def change
    add_column :product_mutations, :total_value, :float
  end
end
