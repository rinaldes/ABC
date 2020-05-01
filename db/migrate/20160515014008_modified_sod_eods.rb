class ModifiedSodEods < ActiveRecord::Migration
  def change
    add_column :sod_eods, :start_200, :float
    add_column :sod_eods, :start_100, :float
    add_column :sod_eods, :start_50, :float
    add_column :sod_eods, :end_200, :float
    add_column :sod_eods, :end_100, :float
    add_column :sod_eods, :end_50, :float
  end
end
