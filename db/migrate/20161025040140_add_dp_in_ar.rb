class AddDpInAr < ActiveRecord::Migration
  def change
    add_column :account_receivables, :down_payment, :float
  end
end
