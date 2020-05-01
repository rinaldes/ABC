class AccountPayable < ActiveRecord::Base
  CREDIT = 'Credit'

  belongs_to :supplier
  belongs_to :receiving

  has_many :account_payable_details, :dependent => :destroy
  accepts_nested_attributes_for :account_payable_details, :allow_destroy => true, :reject_if => lambda { |c| c[:amount].blank? }

  has_many :other_charges, :dependent => :destroy
  accepts_nested_attributes_for :other_charges, :allow_destroy => true, :reject_if => lambda { |c| c[:amount].blank? }

  has_many :account_payable_returns_to_suppliers
  has_many :returns_to_suppliers, through: :account_payable_returns_to_suppliers

  has_many :account_payable_receivings
  has_many :receivings, through: :account_payable_receivings

  # after_save :update_receive
  # before_save :count_return_to_supplier

  delegate :name, to: :supplier, prefix: true

  def update_receive
    self.receiving.update_attributes(status: 'close') if self.outstanding_amount == 0
  end

  def count_return_to_supplier
    ReturnsToSupplier.where(supplier_id: supplier_id, status: ProductMutation::RECEIVED).map(&:total).sum
  end

  def self.in_ap_number(in_ap_number)
    if in_ap_number.present?
      where(:ap_number => in_ap_number)
    else
      where(nil)
    end
  end

  def self.in_due_date(in_due_date)
    if in_due_date.present?
      where(:due_date => in_due_date)
    else
      where(nil)
    end
  end

  def self.in_supplier_name(in_supplier_name)
    if in_supplier_name.present?
      joins(:member).where("lower(members.name) LIKE ?", "%#{in_customer_name}%")
    else
      where(nil)
    end
  end

  def self.in_supplier_id(in_supplier_id)
    if in_supplier_id.present?
      where("supplier_id = ?", in_supplier_id)
    else
      where(nil)
    end
  end

  def self.in_receiving
    joins(:receiving).where("receivings.status != 'CLOSED'")
  end

  def recalculate_account_payable
    self.update_attributes(total_paid: count_total_paid, total_discount: count_total_discount, outstanding_amount: count_outstanding)
    # now = Time.now
    # AccountPayable.create ap_number: "AP/#{now.strftime("%m/%y-")}" + sprintf('%06d', AccountPayable.where("extract(year from created_at) = ? and extract(month from created_at) = ?", now.strftime("%Y"), now.strftime("%m")).count + 1), due_date: due_date+supplier.long_term, supplier_id: supplier_id,
    # total_amount: count_outstanding, outstanding_amount: count_outstanding
  end

  def count_total_paid
    self.account_payable_details.sum(:amount).to_f
  end

  def count_total_discount
    (self.retur_amount.to_f + self.deposit.to_f) +  self.other_charges.sum(:amount).to_f + self.count_return_to_supplier
  end

  def count_outstanding
    self.total_amount.to_f - (count_total_paid.to_f + count_total_discount.to_f)
  end

  def self.get_report
    self.group(:supplier_id, :id).having("SUM(outstanding_amount) NOT IN (?)", [0.0, 0])
  end

  def self.get_report_bank_outs(supplier_id, ap_number)
    self.in_supplier_id(supplier_id).in_ap_number(ap_number)
  end

  def self.get_debit_value(bank_out)
    credit = bank_out.outstanding_amount + bank_out.retur_amount + bank_out.total_paid
    bank_out.other_charges.each do |other_charge|
      credit += other_charge.amount unless other_charge.amount.blank? 
    end
    return credit
  end

  def self.get_report_repayments(supplier_id)
    conditions = []
    conditions << "account_payables.supplier_id = #{supplier_id}" if supplier_id.present?
    self.where(conditions.join(' AND '))
  end
end
