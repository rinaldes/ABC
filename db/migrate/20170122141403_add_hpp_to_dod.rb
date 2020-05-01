class AddHppToDod < ActiveRecord::Migration
  def change
    add_column :dibeliowner_details, :hpp, :float
    add_column :dibeliowner_details, :value, :float
  end
end
