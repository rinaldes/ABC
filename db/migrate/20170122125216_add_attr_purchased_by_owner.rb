class AddAttrPurchasedByOwner < ActiveRecord::Migration
  def change
    add_column :dibeliowners, :total_price, :float
    add_column :dibeliowners, :total_value, :float
    add_column :dibeliowners, :total_quantity, :float
    add_column :dibeliowners, :user_id, :integer
  end
end
