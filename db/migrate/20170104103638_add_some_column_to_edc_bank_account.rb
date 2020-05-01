class AddSomeColumnToEdcBankAccount < ActiveRecord::Migration
  def change
    add_column :edc_bank_accounts, :sales_id, :integer
    add_column :edc_bank_accounts, :type, :string
    add_column :edc_bank_accounts, :card_number, :string
    add_column :edc_bank_accounts, :payment_amt, :float
    add_column :edc_bank_accounts, :outstanding_amount, :float
    add_column :edc_bank_accounts, :account_name, :string
    add_column :edc_bank_accounts, :extra_charge, :float
  end
end