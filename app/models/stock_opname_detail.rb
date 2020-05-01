class StockOpnameDetail < ActiveRecord::Base
  belongs_to :product_size
  belongs_to :stock_opname

#  after_create :update_quantity

  def diff
    qty_actual - qty_virtual rescue nil
  end

  def update_quantity
    product_detail = product_size.product_details.find_by_warehouse_id(stock_opname.branch_id)
    if product_detail.present? && qty_actual.present?
      ProductMutation.create product_detail_id: product_detail.id, old_quantity: product_detail.available_qty, moved_quantity: product_detail.available_qty-qty_actual,
        new_quantity: qty_actual, mutation_type: 'Stock Opname', mutation_id: id, quantity_type: 'available_qty'
      product_detail.update_attributes(available_qty: qty_actual)
    else
      self.destroy
    end
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["barcode", "product_size_id", "quantity"]
      all.each do |stock_opname_detail|
        #csv << [stock_opname_detail.code, stock_opname_detail.product_size., stock_opname_detail.address, stock_opname_detail.city, stock_opname_detail.send_address, stock_opname_detail.phone, stock_opname_detail.fax, stock_opname_detail.long_term, stock_opname_detail.suptype]
      end
    end
  end

  def self.to_csv2(options = {})
    CSV.generate(options) do |csv|
      csv << ["article", "colour", "barcode", "barcode_size", "size", "quantity"]
      ProductSize.order("products.barcode ASC").joins(:product).each do |product_size|
        product = product_size.product
        csv << ["#{"'" if product.article.to_s[0] == '0'}#{product.article}", (product.colour_code rescue ''), (product.barcode rescue ''), "#{"'" if product_size.barcode_size.to_s[0] == '0'}#{product_size.barcode_size}", product_size.size_detail.size_number]
      end
    end
  end

  def self.import(file, opname_id)
    row_count = 1
    stock_opname = StockOpname.find(opname_id)
    total_qty = 0
    failed_barcode = []
    barcode_sizes = []
    CSV.foreach(file.path, headers: true) do |row|
      params = ActionController::Parameters.new(row.to_hash)
#      product_size_id = ProductSize.find_by_size_detail_id_and_product_id(SizeDetail.find_by_size_number(params[:size]).id, Product.find_by_barcode(params[:barcode]).id).id rescue nil
      product_size_id = ProductSize.find_by_barcode_size(sprintf('%08d', row['barcode_size'].to_i)).id rescue nil
      #raise product_size_id.inspect
      if product_size_id.blank?
        product_size = ProductSize.where(
          "TRIM(LOWER(article))=TRIM(LOWER('#{params['article'].gsub("'", "''")}')) AND TRIM(LOWER(colour_code))=TRIM(LOWER('#{params['colour']}')) AND LOWER(TRIM(size_number))=LOWER(TRIM('#{row['size']}'))"
        ).joins(:product, :size_detail).first
        if product_size.present?
          product_size.update_attributes(barcode_size: sprintf('%08d', row['barcode_size'].to_i))
          product_size_id = product_size.id
        end
      end
      if product_size_id.present?
        mutation_out_conditions = ["origin_warehouse_id=#{stock_opname.office_id} AND type='GoodTransfer' AND product_size_id=#{product_size_id}"]
        mutation_out_conditions << "product_mutations.created_at > '#{stock_opname.start_date}'" if stock_opname.present?

        return_to_ho_conditions = ["origin_warehouse_id=#{stock_opname.office_id} AND type='ReturnsToHo' AND product_size_id=#{product_size_id}"]
        return_to_ho_conditions << "product_mutations.created_at > '#{stock_opname.start_date}'" if stock_opname.present?

        mutation_in_conditions = ["destination_warehouse_id=#{stock_opname.office_id} AND status='#{ProductMutation::RECEIVED}' AND type='GoodTransfer' AND product_size_id=#{product_size_id}"]
        mutation_in_conditions << "product_mutations.created_at > '#{stock_opname.start_date}'" if stock_opname.present?

        sold_conditions = ["store_id=#{stock_opname.office_id} AND status='FINISHED' AND product_size_id=#{product_size_id}"]
        sold_conditions << "sales.created_at > '#{stock_opname.start_date}'" if stock_opname.present?

        receive_transfer_conditions = ["destination_warehouse_id=#{stock_opname.office_id} AND status='#{ProductMutation::RECEIVED}' AND type='PurchaseTransfer' AND product_size_id=#{product_size_id}"]
        receive_transfer_conditions << "product_mutations.created_at > '#{stock_opname.start_date}'" if stock_opname.present?

        product_detail = ProductDetail.where("warehouse_id=#{stock_opname.office_id} AND product_size_id=#{product_size_id}")
          .select("available_qty+allocated_qty+freezed_qty+rejected_qty+defect_qty+online_qty AS qty")

        stock_opname_detail = stock_opname.stock_opname_details.where(product_size_id: product_size_id).first_or_create

        stock_opname_detail.update_attributes(qty_actual: params[:quantity], sold: SalesDetail.where(sold_conditions.join(' AND ')).joins(:sale).map(&:quantity).compact.sum,
          received_from_transfer: ProductMutationDetail.where(receive_transfer_conditions.join(' AND ')).joins(:product_mutation).map(&:quantity).compact.sum,
          mutation_in: ProductMutationDetail.where(mutation_in_conditions.join(' AND ')).joins(:product_mutation).map(&:quantity).compact.sum,
          mutation_out: ProductMutationDetail.where(mutation_out_conditions.join(' AND ')).joins(:product_mutation).map(&:quantity).compact.sum,
          qty_virtual: product_detail.map(&:qty).compact.sum, retur: ProductMutationDetail.where(return_to_ho_conditions.join(' AND ')).joins(:product_mutation).map(&:quantity).compact.sum)
        total_qty += params[:quantity].to_i
      else
        failed_barcode << params
      end
      barcode_sizes << params['barcode_size']
    end
    barcode_sizes.group_by{|x|x}
    stock_opname.update_attributes(actual_stock: total_qty)
=begin
    CSV.generate({}) do |csv|
      csv << %w(article	colour	barcode	barcode_size	size	quantity system_qty ada_di_so row_count)
      CSV.foreach(file.path, headers: true) do |row|
        product_size = ProductSize.find_by_barcode_size(sprintf('%08d', row['barcode_size'].to_i))
        product_detail = ProductDetail.find_by_product_size_id_and_warehouse_id(product_size.id, 2) rescue nil
        csv << [row['article'], row['colour'], row['barcode'], row['barcode_size'], row['size'], row['quantity'], (product_detail.available_qty rescue ''), (stock_opname.stock_opname_details.find_by_product_size_id(product_size.id).id rescue nil), barcode_sizes.group_by{|x|x}[row['barcode_size']].count]
      end
    end
=end
 #   raise failed_barcode.inspect
#=begin
    CSV.generate({}) do |csv|
      csv << %w(article	colour	barcode	barcode_size	size	quantity system_qty)
      failed_barcode.each do |row|
#        product_size = ProductSize.find_by_barcode_size(sprintf('%08d', row['barcode'].to_i))
 #       product_detail = ProductDetail.find_by_product_size_id_and_warehouse_id(product_size.id, 2) rescue nil
        csv << [row['article'], row['colour'], row['barcode'], row['barcode_size'], row['size'], row['quantity']]
      end
    end
#=end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
