class CreateProductMutationHistories < ActiveRecord::Migration
  def change
    create_table :product_mutation_histories do |t|
      t.integer :product_detail_id
      t.integer :old_quantity
      t.integer :moved_quantity
      t.integer :new_quantity
      t.string :mutation_type
      t.string :quantity_type
      t.integer :product_mutation_detail_id
      t.timestamps
      t.float :price
      t.float :discount
    end
  end
end
