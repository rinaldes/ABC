class PurchaseOrder < ActiveRecord::Base
  has_many :purchase_order_details, dependent: :destroy
  has_many :receivings
  has_many :purchase_requests

  belongs_to :supplier
  belongs_to :head_office
  belongs_to :office, foreign_key: 'head_office'

  APPROVED = 'APPROVED'
  REJECTED = 'REJECTED'
  WAITING_APPROVAL = 'WAITING APPROVAL'
  CLOSED = 'CLOSED'

  accepts_nested_attributes_for :purchase_order_details, reject_if: :all_blank, allow_destroy: true

  def is_waiting_approval?
    status == WAITING_APPROVAL
  end

  def is_closed?
    status == CLOSED
  end

  def received_qty product_size
    ReceivingDetail.where("product_size_id=#{product_size.id} AND purchase_order_id=#{id}").joins(receiving: :purchase_order) .select("SUM(receiving_details.quantity) AS received_qty")
      .group('receiving_details.id').first.received_qty rescue 0
  end

  def outstanding_qty product_size
    pod = PurchaseOrderDetail.find_by_product_size_id_and_purchase_order_id(product_size.id, id)
    return nil if pod.blank? || pod.quantity.blank? || pod.quantity <= 0
    qty = pod.quantity.to_i-received_qty(product_size)
    qty < 0 ? 0 : qty
  end
end
