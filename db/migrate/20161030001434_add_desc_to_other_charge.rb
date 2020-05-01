class AddDescToOtherCharge < ActiveRecord::Migration
  def change
    add_column :other_charges, :desc, :string
    add_column :account_payables, :note, :string
  end
end
