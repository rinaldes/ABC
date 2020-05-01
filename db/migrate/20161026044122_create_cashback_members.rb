class CreateCashbackMembers < ActiveRecord::Migration
  def change
    create_table :cashback_members do |t|
      t.integer :member_id
      t.float :transaction_amount
      t.float :cashback_amount
      t.integer :member_level_id
      t.integer :member_id
      t.integer :cashback_id
      t.timestamps
    end
  end
end
