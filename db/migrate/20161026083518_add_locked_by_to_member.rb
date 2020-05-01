class AddLockedByToMember < ActiveRecord::Migration
  def change
    add_column :members, :locked_by, :string
  end
end
