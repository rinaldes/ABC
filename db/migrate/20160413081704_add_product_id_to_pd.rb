class AddProductIdToPd < ActiveRecord::Migration
  def change
    add_column :product_details, :product_id, :integer
  end
end
