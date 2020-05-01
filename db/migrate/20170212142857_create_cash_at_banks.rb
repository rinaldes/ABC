class CreateCashAtBanks < ActiveRecord::Migration
  def change
    create_table :cash_at_banks do |t|
      t.integer :sod_eod_id
      t.integer :edc_bank_account_id
      t.float :saving_amount
      t.float :required_amount
      t.date :saving_date
      t.timestamps
    end
  end
end
