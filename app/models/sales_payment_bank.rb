class SalesPaymentBank < ActiveRecord::Base
  self.table_name = "sales_payment_bank"

  belongs_to :sale, :class_name => 'Sale', :foreign_key => 'sales_id'

  def self.get_payment_merchant(date, bank_name)
    payment_merchants = self.joins(:sale).where("date(sales.transaction_date) = ?", date)
    debits = payment_merchants.where("debit_id is not null and LOWER(bank_name) = ?", bank_name).sum(:debit_amt)
    credits = payment_merchants.where("credit_id is not null and LOWER(bank_name) = ?", bank_name).sum(:credit_amt)
    debits + credits
  end

  def self.get_payment_transfer(date, bank_name)
    self.joins(:sale).where("date(sales.transaction_date) = ? AND transfer_id is not null AND LOWER(bank_name) = ?", date, bank_name).sum(:transfer_amt)
  end
end
