class PurchaseRequest < ActiveRecord::Base

  has_many :purchase_request_details

  belongs_to :supplier
  belongs_to :branch
  belongs_to :purchase_order

  accepts_nested_attributes_for :purchase_request_details, reject_if: :all_blank, allow_destroy: true

  WAITING_APPROVAL = 'WAITING APPROVAL'
  TRANSFER_ON_PROGRESS = 'TRANSFER ON PROGRESS'

  validate :check_article

  def check_article
    purchase_request_details.each{|prd|
#      errors.add(:article, "Article #{prd.product_size.product.article} are in process PR, can't be requested in this time.") if PurchaseRequestDetail.joins(:purchase_request, product_size: :product).where("article='#{prd.product_size.product.article}' AND branch_id=#{branch_id} AND purchase_requests.status!='Closed'").limit(1).present?
    }
  end

  def is_waiting_approval?
    status == WAITING_APPROVAL
  end

  def self.get_number(time_now)
    "PR/branch/supplier/#{time_now.strftime("%Y-%m-%d")}/#{
      sprintf('%06d',
        (PurchaseRequest.where("extract(year from date) = ? and extract(month from date) = ?", time_now.strftime("%Y"), time_now.strftime("%m")).last.number.split('-')[1].to_i rescue 0) + 1)
    }"
  end
end