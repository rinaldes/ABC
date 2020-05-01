class ChangeBarcode < ActiveRecord::Base
  after_create :create_quantity_log
  def create_quantity_log
    old_product_detail = old_product_size.product_details.where(warehouse_id: sale.store_id).first_or_create
    new_product_detail = new_product_size.product_details.where(warehouse_id: sale.store_id).first_or_create

    ProductMutationHistory.create product_detail_id: product_detail.id, old_quantity: product_detail.available_qty, moved_quantity: quantity, new_quantity: new_quantity,
      mutation_type: 'Sales', product_mutation_detail_id: id, quantity_type: 'available_qty', id: (ProductMutationHistory.last.id+1 rescue 1)
    old_product_detail.update_attributes(available_qty: old_product_detail.available_qty-quantity)
    new_product_detail.update_attributes(available_qty: new_product_detail.available_qty+quantity)
  end
end
