class AddReceiveIdToRts < ActiveRecord::Migration
  def change
    add_column :returns_to_suppliers, :receiving_id, :integer
  end
end
