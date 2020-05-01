class CreateMemberBalanceMutations < ActiveRecord::Migration
  def change
=begin
    create_table :member_balance_mutations do |t|
      t.integer :mutation_id
      t.integer :member_id
      t.string :mutation_type
      t.float :mutation_value
      t.string :transaction_no
      t.timestamps
    end
=end
  end
end
