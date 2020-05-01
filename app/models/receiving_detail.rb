class ReceivingDetail < ActiveRecord::Base
  belongs_to :receiving
  belongs_to :product_size

  after_create :generate_history
  after_create :generate_total_price

  def product
    product_size.product
  end

  def generate_history
    product_detail = product_size.product_details.find_by_warehouse_id(receiving.head_office_id)
    if product_detail.present? && quantity.to_i > 0
      new_quantity = product_detail.available_qty.to_i+quantity.to_i
      ProductMutationHistory.create product_detail_id: product_detail.id, old_quantity: product_detail.available_qty, moved_quantity: quantity, new_quantity: new_quantity,
        product_mutation_detail_id: id, quantity_type: 'available_qty', mutation_type: 'Receiving', price: product_size.product.cost_of_products.to_f*quantity.to_i, id: (ProductMutationHistory.last.id rescue 0)+1
      product_detail.update_attributes(available_qty: new_quantity)
    end
  end

  def generate_total_price
    self.update_attributes(total_price: quantity.to_i*(product.cost_of_products.to_f rescue 0), hpp: (product.cost_of_products rescue 0), value: (product.selling_price rescue 0))
  end
end