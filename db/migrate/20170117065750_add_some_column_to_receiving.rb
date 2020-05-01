class AddSomeColumnToReceiving < ActiveRecord::Migration
  def change
  	add_column :receivings, :total_before_discount, :float
  	add_column :receivings, :total_after_discount, :float
  	add_column :receivings, :discount1, :float
  	add_column :receivings, :discount2, :float
  	add_column :receivings, :discount3, :float
  	add_column :receivings, :discount4, :float
  end
end