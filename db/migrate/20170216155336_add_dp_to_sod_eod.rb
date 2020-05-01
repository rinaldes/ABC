class AddDpToSodEod < ActiveRecord::Migration
  def change
    add_column :sod_eods, :dp_masuk, :float
    add_column :sod_eods, :dp_keluar, :float
  end
end