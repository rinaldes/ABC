class CreateAccountPayableReturnsToSuppliers < ActiveRecord::Migration
  def change
    create_table :account_payable_returns_to_suppliers do |t|
      t.integer :returns_to_supplier_id
      t.integer :account_payable_id
      t.timestamps
    end
  end
end
