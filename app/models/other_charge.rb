class OtherCharge < ActiveRecord::Base
  belongs_to :account_payable

  def self.get_amount_by_account_payable_ids_and_name(account_payable_ids, name)
  	self.where("account_payable_id IN (?) AND name = ?", account_payable_ids, name).pluck(:amount).sum
  end
end
