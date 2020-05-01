class CreateEdcBankAccounts < ActiveRecord::Migration
  def change
    create_table :edc_bank_accounts do |t|
      t.string :bank_name
      t.string :account_number
      t.float :credit_charge
      t.timestamps
    end
  end
end
