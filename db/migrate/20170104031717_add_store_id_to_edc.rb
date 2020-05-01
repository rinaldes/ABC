class AddStoreIdToEdc < ActiveRecord::Migration
  def change
    add_column :edc_machines, :store_id, :integer
  end
end
