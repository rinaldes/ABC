class AddQuantityToAccountPayableDetail < ActiveRecord::Migration
  def change
    add_column :account_payable_details, :quantity, :integer
  end
end