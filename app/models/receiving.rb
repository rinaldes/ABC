class Receiving < ActiveRecord::Base
  has_many :receiving_details, dependent: :destroy
  has_many :account_payable_receivings
  has_many :account_payables, through: :account_payable_receivings
  has_many :pr_transfer_products
  has_many :purchase_transfers, through: :pr_transfer_products
  has_many :returns_to_suppliers

  belongs_to :supplier
  belongs_to :purchase_order
  belongs_to :head_office

  has_one :account_payable

  READY_FOR_INSPECTION = 'READY FOR INSPECTION'
  INSPECTED = 'INSPECTED'
  CLOSED = 'CLOSED'

  accepts_nested_attributes_for :receiving_details, :reject_if => :all_blank, :allow_destroy => true

  validates :consigment_number, presence: true
  validates :date, presence: true
  validates :faktur_date, presence: true

  after_create :create_ap

#  validate :check_stock, on: :create

  def check_stock
    receiving_details.each{|p|
      #errors.add(:quantity, " in size #{p.product_size.size_detail.size_number} can't be more than PO quantity") if p.product_size.size_detail.present? && p.quantity.to_i > ProductDetail.find_by_warehouse_id_and_product_size_id(origin_warehouse_id, p.product_size_id).available_qty.to_i
    }
  end

  def create_ap
    now = Time.now
    Receiving.where("id NOT IN (SELECT receiving_id FROM account_payable_receivings)").group_by(&:supplier_id).each{|receiving|
      ap_number = "AP/#{now.strftime("%m/%y-")}" + sprintf('%06d', AccountPayable.where("extract(year from created_at) = ? and extract(month from created_at) = ?", now.strftime("%Y"), now.strftime("%m")).count+1)
      total_amount = receiving[1].map(&:total).sum
      supplier = Supplier.find_by_id receiving[0]
      if supplier.present?
        due_date = now+supplier.long_term.to_i.days
        due_day = due_date.strftime('%d').to_i
        due_day = due_day < 15 || due_day-15 < 30-due_day ? 15 : due_date.strftime('%m').to_i == 2 ? due_date.end_of_month.strftime('%d').to_i : 30
        ap = AccountPayable.where(supplier_id: receiving[0], due_date: due_date.strftime("%Y-%m-#{due_day}")).first_or_create
        ap.ap_number = ap_number if ap.ap_number.blank?
        ap.total_amount = total_amount
        ap.outstanding_amount = ap.outstanding_amount.to_f + total_amount.to_f
        ap.payment_term = '-'
        ap.save
        receiving[1].each{|r|
          AccountPayableReceiving.create account_payable_id: ap.id, receiving_id: r.id
        }
      end
    }
  end

  def total
    receiving_details.map(&:total_price).sum
  end

  def total_value
    receiving_details.map{|r|r.quantity.to_f*r.value.to_f}.sum
  end

  def outstanding_amount
    receiving_details.map{|r|r.outstanding_qty.to_f*r.hpp.to_f}.sum
  end

  def self.get_number(time_now)
    "RC/ho-cabang/supplier/#{time_now.strftime("%Y-%m-%d")}/#{
      sprintf('%06d',
        (Receiving.where("extract(year from date) = ? and extract(month from date) = ?", time_now.strftime("%Y"), time_now.strftime("%m")).last.number.split('-')[1].to_i rescue 0) + 1)
    }"
  end

  def self.get_journal_memos
    self.joins(:account_payables, :supplier).group("receivings.id").order("receivings.created_at")
  end

  def self.get_sum_total_receiving(receivings)
    array_of_total = Array.new
    receivings.each do |receiving|
      array_of_total.push(receiving.try(:total))
    end
    array_of_total.sum
  end
end