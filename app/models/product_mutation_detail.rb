class ProductMutationDetail < ActiveRecord::Base
  after_create :generate_history

  belongs_to :product_size
  belongs_to :product_mutation

  def generate_history
    product_detail = product_size.product_details.find_by_warehouse_id(product_mutation.origin_warehouse_id)
    self.update_attributes(hpp: product_size.product.cost_of_products, value: product_size.product.selling_price)
    if product_detail.present? && quantity.to_i > 0
      new_quantity = product_detail.available_qty.to_i-quantity.to_i
      ProductMutationHistory.create product_detail_id: product_detail.id, old_quantity: product_detail.available_qty, moved_quantity: quantity*-1, new_quantity: new_quantity,
        product_mutation_detail_id: id, quantity_type: 'available_qty', mutation_type: product_mutation.class.to_s.titleize, price: product_size.product.cost_of_products*quantity,
        id: (ProductMutationHistory.last.id rescue 0)+1
      product_detail.update_attributes(available_qty: new_quantity)
    end
  end

  def product_received_by_destination_branch
    product_detail = product_size.product_details.find_by_warehouse_id(product_mutation.destination_warehouse_id)
    if product_detail.present? && quantity.to_i > 0
      new_quantity = product_detail.available_qty.to_i+quantity.to_i
      ProductMutationHistory.create product_detail_id: product_detail.id, old_quantity: product_detail.available_qty, moved_quantity: quantity, new_quantity: new_quantity,
        product_mutation_detail_id: id, quantity_type: 'available_qty', mutation_type: "#{product_mutation.class.to_s.titleize} Receipt", price: product_size.product.cost_of_products*quantity,
        id: (ProductMutationHistory.last.id rescue 0)+1
      product_detail.update_attributes(available_qty: new_quantity)
    end
  end
end
