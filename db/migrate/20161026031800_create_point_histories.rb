class CreatePointHistories < ActiveRecord::Migration
  def change
    create_table :point_histories do |t|
      t.float :additional_point
      t.float :old_point
      t.float :new_point
      t.float :total_current_price
      t.float :total_accumulated_price
      t.integer :member_id
      t.timestamps
    end
  end
end
