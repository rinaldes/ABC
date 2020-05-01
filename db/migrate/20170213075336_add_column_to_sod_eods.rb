class AddColumnToSodEods < ActiveRecord::Migration
  def change
    add_column :sod_eods, :tombokan, :float
    add_column :sod_eods, :cash2, :float
    add_column :sod_eods, :dp, :float
    add_column :sod_eods, :input_service, :float
    add_column :sod_eods, :lain_lain, :float
  end
end