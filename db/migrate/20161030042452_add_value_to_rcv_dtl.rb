class AddValueToRcvDtl < ActiveRecord::Migration
  def change
    add_column :receiving_details, :value, :float
  end
end
