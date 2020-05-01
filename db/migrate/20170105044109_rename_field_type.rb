class RenameFieldType < ActiveRecord::Migration
  def change
  	rename_column :edc_bank_accounts, :type, :tipe
  end
end
