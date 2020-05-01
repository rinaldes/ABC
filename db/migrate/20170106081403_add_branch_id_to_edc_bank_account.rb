class AddBranchIdToEdcBankAccount < ActiveRecord::Migration
  def change
    add_column :edc_bank_accounts, :branch_id, :integer
  end
end
