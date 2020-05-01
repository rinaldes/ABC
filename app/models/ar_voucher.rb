class ArVoucher < Voucher
  has_many :ar_voucher_payment_schedules
  has_many :ar_voucher_details
  belongs_to :office
  accepts_nested_attributes_for :ar_voucher_payment_schedules, allow_destroy: true
  accepts_nested_attributes_for :ar_voucher_details, allow_destroy: true
  after_create :generate_detail
  attr_accessor :code

  def generate_detail
    voucher_details.create voucher_code: code, generated_date: Time.now, available: true
  end
end