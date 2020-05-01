class AccountPayableDetail < ActiveRecord::Base
   belongs_to :account_payable
   before_save :set_receive_id

  def set_receive_id
		# self.set_receive_id = self.account_payable.receive_id
  end

  def self.get_repayment_detail(account_payable_ids)
  	account_payable_detail = self.where("account_payable_id IN (?)", account_payable_ids)
  	cash = account_payable_detail.where("method = ?", "Cash")
  	transfer = account_payable_detail.where("method = ?", "Transfer")
  	giro = account_payable_detail.where("method = ?", "Giro")

  	return cash, transfer, giro
  end
end
