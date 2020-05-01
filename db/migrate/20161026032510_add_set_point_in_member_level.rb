class AddSetPointInMemberLevel < ActiveRecord::Migration
  def change
    add_column :member_levels, :set_point, :float
  end
end
