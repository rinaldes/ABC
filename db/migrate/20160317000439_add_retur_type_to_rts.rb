class AddReturTypeToRts < ActiveRecord::Migration
  def change
    add_column :returns_to_suppliers, :return_type, :string #Inv, Manual
  end
end
