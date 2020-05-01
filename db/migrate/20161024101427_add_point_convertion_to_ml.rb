class AddPointConvertionToMl < ActiveRecord::Migration
  def change
    add_column :member_levels, :point_convertion, :float
  end
end
