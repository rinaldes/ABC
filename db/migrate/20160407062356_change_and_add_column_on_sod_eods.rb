class ChangeAndAddColumnOnSodEods < ActiveRecord::Migration
  def change
    add_column :sod_eods, :machine_id, :string
    change_column :sod_eods, :start_time, :timestamp
    change_column :sod_eods, :end_time, :timestamp
  end
end
