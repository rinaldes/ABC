class SalesDetail < ActiveRecord::Base

  attr_accessor :store_id, :product_detail_id
  belongs_to :product_size
  belongs_to :product
  belongs_to :sale

  scope :spg, select(:spg_user_name).uniq

  after_create :create_quantity_log

  # validates :quantity, presence: {message: 'harus diisi'}
  # validates :goods_detail_id, presence: {message: 'harus diisi'}
  # validates :price, presence: {message: 'harus diisi'}
  # validates :price_after_discount, presence: {message: 'harus diisi'}
  # validate :check_stock

  def total_per_detail
    quantity * price_after_discount
  end

  def create_quantity_log
    product_detail = product_size.product_details.where(warehouse_id: sale.store_id).first_or_create rescue (ProductDetail.find product_detail_id)

    new_quantity = product_detail.available_qty.to_i-quantity.to_i rescue 0
    ProductMutationHistory.create product_detail_id: product_detail.id, old_quantity: product_detail.available_qty, moved_quantity: quantity, new_quantity: new_quantity,
      mutation_type: 'Sales', product_mutation_detail_id: id, quantity_type: 'available_qty', id: (ProductMutationHistory.last.id+1 rescue 1)
    product_detail.update_attributes(available_qty: new_quantity)
  end

  private

  def check_stock
    self.errors.add(:sales_detail, "stok tidak mencukupi") and return false unless (goods_size.goods_details.find_by_store_id(store_id.to_i).quantity rescue 0) > quantity
  end
end
