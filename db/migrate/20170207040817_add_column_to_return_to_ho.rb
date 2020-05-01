class AddColumnToReturnToHo < ActiveRecord::Migration
  def change
  	add_column :product_mutations, :batal_retur, :boolean
  	add_column :product_mutations, :ganti_barcode, :boolean
  end
end