class ChangeMutationIdToString < ActiveRecord::Migration
  def change
    change_column :member_balance_mutations, :mutation_id, :string
    change_column :member_point_mutations, :mutation_id, :string
  end
end
