class CreateChangeBarcodes < ActiveRecord::Migration
  def change
    create_table :change_barcodes do |t|
      t.integer :old_product_size_id
      t.integer :new_product_size_id
      t.integer :head_office_id
      t.integer :quantity
      t.timestamps
    end
  end
end
