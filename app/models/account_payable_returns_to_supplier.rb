class AccountPayableReturnsToSupplier < ActiveRecord::Base
	belongs_to :returns_to_supplier
  belongs_to :account_payable
end
