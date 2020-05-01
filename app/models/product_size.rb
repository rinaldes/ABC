class ProductSize < ActiveRecord::Base
  belongs_to :size_detail
  belongs_to :product

  has_many :product_details

  accepts_nested_attributes_for :product_details, reject_if: :all_blank, allow_destroy: true

   after_create :generate_product_details

  # validate :check_min_stock

  def check_min_stock
    #errors.add(:ProductDetails, " min_stock harus diisi") if product_details.blank?
  end
  def generate_product_details
    Office.all.each{|office|
      pd = ProductDetail.where(product_size_id: id, warehouse_id: office.id, min_stock: (default_min_stock || 0)).first_or_create
      pd.update_attributes(product_id: product_id)
    }
  end
end
