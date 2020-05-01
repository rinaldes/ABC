class AddMemberTypeIdToMembers < ActiveRecord::Migration
  def change
    add_column :members, :member_type_id, :integer
  end
end
