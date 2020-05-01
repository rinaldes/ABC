class AccountReceivable < ActiveRecord::Base
  belongs_to :member
  belongs_to :office, foreign_key: :branch_id

  has_many :payments, :dependent => :destroy
  accepts_nested_attributes_for :payments, :allow_destroy => true, :reject_if => lambda { |c| c[:amount].blank? }

  validates :due_date, presence: { message: "Payment Due Date can't be blank!" }, on: :update, if: :is_pending_payment

  def is_pending_payment
    self.payment_term.try(:downcase) == 'pending payment'
  end

  def is_credit
    self.payment_term.try(:downcase) == 'credit'
  end

  def self.in_ar_number(in_ar_number)
    if in_ar_number.present?
      where(:ar_number => in_ar_number)
    else
      where(nil)
    end
  end

  def self.in_transaction_no(in_transaction_no)
    if in_transaction_no.present?
      where(:transaction_number => in_transaction_no)
    else
      where(nil)
    end
  end

  def self.in_customer_name(in_customer_name)
    if in_customer_name.present?
      joins(:member).where("lower(members.name) LIKE ?", "%#{in_customer_name}%")
    else
      where(nil)
    end
  end

  def self.get_total_account_receivables(member_id)
    total_amount = self.where("member_id = ?", member_id).pluck(:total_amount)
    total_amount.inject{ |sum, el| sum + el } if total_amount.present?
  end
end
