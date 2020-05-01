class OngkosKirim < ActiveRecord::Migration
  def change
    add_column :returns_to_suppliers, :ongkir, :float
    add_column :product_mutations, :ongkir, :float
  end
end
