class AddReturnsToSupplierIdToRtho < ActiveRecord::Migration
  def change
    add_column :product_mutations, :returns_to_supplier_id, :integer
  end
end
