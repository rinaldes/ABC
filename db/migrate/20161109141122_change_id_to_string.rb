class ChangeIdToString < ActiveRecord::Migration
  def change
    change_column :member_balance_mutations, :id, :string
  end
end
