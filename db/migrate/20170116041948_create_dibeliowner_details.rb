class CreateDibeliownerDetails < ActiveRecord::Migration
  def change
    create_table :dibeliowner_details do |t|
      t.integer :quantity
      t.integer :product_size_id
      t.integer :purchase_transfer_id
      t.timestamps
    end
  end
end
