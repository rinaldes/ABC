class AddIndexToMutationId < ActiveRecord::Migration
  def change
    add_index :member_balance_mutations, :mutation_id
    add_index :member_point_mutations, :mutation_id
  end
end
