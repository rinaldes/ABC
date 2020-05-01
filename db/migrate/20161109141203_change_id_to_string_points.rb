class ChangeIdToStringPoints < ActiveRecord::Migration
  def change
    change_column :member_point_mutations, :id, :string
  end
end
