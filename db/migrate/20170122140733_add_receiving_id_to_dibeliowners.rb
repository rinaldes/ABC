class AddReceivingIdToDibeliowners < ActiveRecord::Migration
  def change
    add_column :dibeliowners, :receiving_id, :integer
  end
end
