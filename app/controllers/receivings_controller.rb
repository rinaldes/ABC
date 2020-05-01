class ReceivingsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :find_receipt, only: [:show, :mark_as_inspected, :print_to_pdf]
  before_filter :can_view_receiving, only: [:index, :show]
  before_filter :can_manage_receiving, only: [:new, :create, :edit, :update, :destroy]

  def autocomplete_receiving_number
    hash = []
    conditions = ["receivings.status<>'#{Receiving::CLOSED}'"]
    conditions << "LOWER(number) LIKE LOWER('%#{params[:term]}%')" if params[:term].present?
    conditions << "LOWER(consigment_number) LIKE LOWER('%#{params[:consignment_number]}%')" if params[:consignment_number].present?
    conditions << "number NOT IN (#{params[:present_receiving]})" if params[:present_receiving].present?
    @receivings = Receiving.where(conditions.join(" AND ")).joins("LEFT JOIN purchase_orders ON purchase_orders.id=receivings.purchase_order_id").joins(:supplier)
      .select("receivings.*, suppliers.name AS supplier_name, purchase_orders.number AS po_number, total_qty, received_qty, outstanding_qty").limit(25).paginate(:page => params[:page], :per_page => 100) || []
    @receivings.collect do |receiving|
      supplier = receiving.supplier
      next if supplier.blank?
      hash << {
        id: receiving.id, label: params[:consignment_number].present? ? receiving.consigment_number : receiving.number,
        value: params[:consignment_number].present? ? receiving.consigment_number : receiving.number, date: receiving.date,
        supplier_code: supplier.code, supplier_name: supplier.name, supplier_address: supplier.address, supplier_id: supplier.id, consignment_number: receiving.consigment_number,
        number: receiving.number
      }
    end
    respond_to do |format|
      format.js
      format.json {render json: hash}
    end
  end

  def search_product
    conditions = []
    receiving_id = Receiving.find_by_number(params[:receiving_id]).id rescue nil
    conditions << "LOWER(suppliers.code)=LOWER('#{params[:supplier_code]}')" if params[:supplier_code].present?
    conditions << "LOWER(brands.name) LIKE LOWER('%#{params[:brand_name]}%')" if params[:brand_name].present?
    conditions << "LOWER(article) LIKE LOWER('%#{params[:article]}%')" if params[:article].present?
    conditions << "LOWER(m_classes.name) LIKE LOWER('%#{params[:m_class_name]}%')" if params[:m_class_name].present?
    conditions << "barcode NOT IN (#{params[:present_product]})" if params[:present_product].present?
    conditions << "LOWER(barcode) LIKE LOWER('%#{params[:barcode]}%')" if params[:barcode].present?
    conditions << "products.id IN (SELECT product_id FROM product_sizes WHERE product_sizes.id IN (SELECT product_size_id FROM receiving_details WHERE receiving_id=#{receiving_id}))" if receiving_id.present?
    @products = Product.where(conditions.join(' AND ')).joins(:m_class, brand: :supplier).paginate(page: params[:page], per_page: 10) || []
  end

  def index
    get_paginated_receivings
    respond_to do |format|
      format.html
      format.js
      format.xls
    end
  end

  def add_product
    @product = Product.find(params[:id])
    @supplier = @product.brand.supplier rescue nil
    @list_product = ProductDetail.where("warehouse_id=#{(current_user.branch.id rescue Branch.first.id)} AND products.id=#{@product.id}").joins(product_size: [:product])
    respond_to do |format|
      format.js
    end
  end

  def add_product_po
    @purchase_order = PurchaseOrder.find_by_number(params[:number])
    @supplier = @purchase_order.supplier rescue nil
    @list_product = ProductDetail.where("warehouse_id=#{(current_user.branch.id rescue Branch.first.id)} AND product_size_id IN (SELECT product_size_id FROM purchase_order_details WHERE purchase_order_id=#{@purchase_order.id})").joins(product_size: [:product]).group_by{|product_detail|product_detail.product_size.product_id}
    @received_products = Receiving.where("purchase_order_id=?", @purchase_order.id)
    @quantities = {}
    respond_to do |format|
      format.js
    end
  end

  def mark_as_inspected
    if @receiving.status != Receiving::INSPECTED && @receiving.update_attributes(status: Receiving::INSPECTED)
      @receiving.receiving_details.map{|detail|[detail.product_size_id, detail.quantity]}.each{|receipt_detail|
        product_detail = ProductDetail.find_by_warehouse_id_and_product_size_id(current_user.head_office_id, receipt_detail[0])
        product_detail.update_attributes(available_qty: product_detail.available_qty+receipt_detail[1]) if receipt_detail[1].present?
      }
      flash[:notice] = t(:successfully_inspected)
    else
      flash[:error] = t(:already_inspected_by_another_user)
    end
    redirect_to receivings_url
  end

  def show
    @receiving = Receiving.find params[:id]
    @purchase_order = @receiving.purchase_order
    @supplier = @receiving.supplier
    @list_product = ProductDetail
      .where("warehouse_id=#{(current_user.branch.id rescue Branch.first.id)} AND product_size_id IN (SELECT product_size_id FROM receiving_details WHERE receiving_id=#{@receiving.id})")
      .joins(product_size: [:product]).group_by{|pd|pd.product_size.product_id}
    load_master
  end


  def print_to_pdf
    # tables = [['CODE', 'MERK', 'ARTICLE', 'WARNA', 'DEPARTMENT', 'TOTAL HARGA', 'UKURAN']]
    @supplier = @receiving.supplier
    @purchase_order = @receiving.purchase_order
    # @receiving.receiving_details.group_by{|prd|prd.product_size.product_id}.each{|psd|
    #   size = @receiving.receiving_details.joins(:product_size).where("product_sizes.product_id = ?", psd[1].first.product_size.product_id).map{|sz| sz.product_size.size_detail.size_number }
    #   product_size = psd[1].first.product_size
    #   product = product_size.product
    #   tables << [
    #     product.barcode, product.brand.name, product.article, product.full_colour.join('/'), product.m_class.department.name, product.cost_of_products, size.join(', ')
    #   ]
    # }
    # Prawn::Document.generate("#{Rails.root.to_s}/public/ActiveLicense.pdf") do |pdf|
    #   pdf.text "<b>FORM PENERIMAAN BARANG</b>", :style => :normal, :inline_format => true, align: :center
    #   pdf.move_down(7)
    #   pdf.text "Tanggal Receiving       : #{@receiving.date.strftime('%d-%m-%Y')}", :style => :normal, :inline_format => true
    #   pdf.move_down(7)
    #   pdf.text "No. Receiving              : #{@receiving.number}", :style => :normal, :inline_format => true
    #   pdf.move_down(7)
    #   pdf.text "Consigment No             : #{@receiving.consigment_number}", :style => :normal, :inline_format => true
    #   pdf.move_down(7)
    #   pdf.text "Receiving Note            : #{@receiving.note || '-'}", :style => :normal, :inline_format => true

    #   pdf.move_down(7)
    #   pdf.text "Tanggal PO       : #{purchase_order.date.strftime('%d-%m-%Y')}", :style => :normal, :inline_format => true
    #   pdf.move_down(7)
    #   pdf.text "No. PO              : #{purchase_order.number}", :style => :normal, :inline_format => true
    #   pdf.move_down(7)
    #   pdf.text "PO Note            : #{purchase_order.note || '-'}", :style => :normal, :inline_format => true

    #   pdf.move_down(7)
    #   pdf.text "Kode Supplier    : #{supplier.code}", :style => :normal, :inline_format => true
    #   pdf.move_down(7)
    #   pdf.text "Supplier            : #{supplier.name}", :style => :normal, :inline_format => true
    #   pdf.move_down(7)
    #   pdf.text "Alamat              : #{supplier.address}", :style => :normal, :inline_format => true
    #   pdf.table tables
    #   send_data pdf.render, :type => "application/pdf", :filename => "Receiving #{@receiving.number}.pdf"
    # end
    html = render_to_string(:layout => "pdf_layout.html") 
    pdf = WickedPdf.new.pdf_from_string(html, :orientation => 'Portrait')
    send_data(pdf, 
      :filename    => "Receiving #{@receiving.number}.pdf", 
      :disposition => 'attachment',
    ) 
  end

  def new
    @receiving = Receiving.new date: Time.now.strftime('%d-%m-%Y'), faktur_date: Time.now.strftime('%d-%m-%Y')
    load_master
    respond_to do |format|
      format.html
    end
  end

  def edit
    @receiving = Receiving.find params[:id]
    @purchase_order = @receiving.purchase_order
    @supplier = @receiving.supplier
    @list_product = ProductDetail
      .where("warehouse_id=#{(current_user.branch.id rescue Branch.first.id)} AND product_size_id IN (SELECT product_size_id FROM receiving_details WHERE receiving_id=#{@receiving.id})")
      .joins(product_size: [:product]).group_by{|pd|pd.product_size.product_id}
    load_master
    respond_to do |format|
      format.html
    end
  end

  def get_last_number
    render json: {
      number: (('%07d' % (((Receiving.where("supplier_id=#{params[:supplier_id]} AND extract(YEAR FROM date)=#{Time.now.year}").order("id DESC").limit(1)[0].number.last.to_i rescue 0) +1))))
    }
  end

  def create
    quantity = params[:receiving][:receiving_details_attributes].values.map{|rc|rc['quantity'].to_i}.sum
    @purchase_order = PurchaseOrder.find_by_id(params[:receiving][:purchase_order_id])
    supplier = Supplier.find_by_id params[:receiving][:supplier_id]
    outstanding_qty = @purchase_order.total_qty-quantity-@purchase_order.receivings.map(&:received_qty).sum if @purchase_order.present?
    @receiving = Receiving.new(
      receiving_params.merge(due_date: Time.now+supplier.long_term.to_i.days, date: Time.now, outstanding_amount: params[:receiving][:total], received_qty: quantity,
      outstanding_qty: (outstanding_qty < 0 ? 0 : outstanding_qty rescue nil))
    )
    respond_to do |format|
      if @receiving.save
        brand = Brand.find(@receiving.receiving_details.first.product_size.product.brand_id)
        total_price_before = (@receiving.receiving_details.map{|rcv|rcv.quantity.to_i*(rcv.product_size.product.harga_bandrol rescue 0)}).sum
        disc1 = total_price_before * brand.discount_percent1 / 100
        price_disc1 = total_price_before - disc1
        disc2 = price_disc1 * brand.discount_percent2 / 100
        price_disc2 = price_disc1 - disc2
        disc3 = price_disc2 * brand.discount_percent3 / 100
        price_disc3 = price_disc2 - disc3
        disc4 = price_disc3 * brand.discount_percent4 / 100
        price_disc4 = price_disc3 - disc4

        @receiving.update_attributes(total_after_discount: price_disc4, total_before_discount: total_price_before, discount1: disc1, discount2: disc2, discount3: disc3, discount4: disc4,
          discount_percent1: brand.discount_percent1, discount_percent2: brand.discount_percent2, discount_percent3: brand.discount_percent3, discount_percent4: brand.discount_percent4)

        hash = {}
        params[:receiving][:receiving_details_attributes].values.map{|a|
          hash = hash.merge(a.values[1] => a.values[0])
        }
        po = PurchaseOrder.find_by_number(params[:pr_name])
        if po.present?
          detail = po.purchase_order_details
          po_closed = false
          Receiving.where("purchase_order_id=#{po.id}").group_by(&:product_size_id).each{|b|
            if detail.find_by_product_size_id(b[0]).quantity >= b[1].map(&:quantity).compact.sum+hash["#{b[0]}"].to_i
              po_closed = false
              break
            end
            po_closed = true
          }
          po.update_attributes(status: pr_closed ? 'CLOSED' : PurchaseRequest::TRANSFER_ON_PROGRESS)
        end
        flash[:notice] = t(:successfully_created)
      else
        flash.now[:error] = @receiving.errors.full_messages.join('<br/>')
      end
      format.js
    end
  end

  def update
    @receiving = Receiving.find(params[:id])
    r_quantity = params[:receiving][:receiving_details_attributes].values.map{|rc|rc['quantity'].to_i}.sum
    if @receiving.update_attributes(receiving_params.merge(status: params[:receiving][:status]))
      receiving_details = ReceivingDetail.where(receiving_id: (@receiving.id rescue nil))
      params[:receiving][:receiving_details_attributes].each{|rd, i|  
        quantity = params[:receiving][:receiving_details_attributes][rd][:quantity]
        size = params[:receiving][:receiving_details_attributes][rd][:product_size_id]
        key = "#{Time.now.to_i}#{i}#{i}";
        #raise rd.inspect
        @receiving.update_attributes(received_qty:r_quantity)
        # product_size_id
        # warehouse_id
        # product_id
        @rede = ReceivingDetail.find_by_product_size_id_and_receiving_id(size.to_i, @receiving.id)
        @pede = ProductDetail.find_by_product_size_id_and_warehouse_id(size.to_i, @receiving.head_office_id)
        old_avai_qty = @pede.available_qty
        old_qty = @rede.quantity
        #raise old_avai_qty.inspect
        real_qty = old_avai_qty.to_i - old_qty.to_i

        ReceivingDetail.find_by_product_size_id_and_receiving_id(size.to_i, @receiving.id).update_attributes(quantity:quantity)
        @pede.update_attributes(available_qty: real_qty)
        
      }
      flash[:notice] = 'Receiving was successfully updated.'
      redirect_to receivings_path
    else
      @purchase_order = @receiving.purchase_order
      @supplier = @receiving.supplier
      @list_product = ProductDetail.where("warehouse_id=#{(current_user.branch.id rescue Branch.first.id)}").joins(product_size: [:product]).group_by{|pd|pd.product_size.product_id}
      flash[:error] = @receiving.errors.full_messages.join('</br>')
      render "edit"
    end
  end

  def destroy
    @receiving = Receiving.find(params[:id])
    @receiving.destroy
    get_paginated_receivings
    respond_to do |format|
      format.js
    end
  end

  def search
    @receivings = Receiving.search(params[:search]).uniq.paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      @receiving = Receiving.new
      format.js
    end
  end

  def get_number
    @receiving_number = Receiving.number(params)
    respond_to do |format|
      format.js
    end
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def load_master
    load_supplier
    @products = Product.select("barcode, id").limit(7).order("barcode").map{|product|[product.barcode, product.id]}
    @orders = PurchaseOrder.select("number, id").limit(7).order("number").map{|product|[product.number, product.id]}
  end

  def get_purchase_order
    @order = PurchaseOrder.find_by_number(params[:number])
    respond_to do |format|
      format.js
    end
  end

private
  def get_paginated_receivings
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @receivings = Receiving.where(conditions.join(' AND ')).order(default_order('receivings')).joins(:supplier)
      .joins("LEFT JOIN purchase_orders ON purchase_orders.id=receivings.purchase_order_id")
      .select("receivings.*, suppliers.name AS supplier_name, purchase_orders.number AS po_number, total_qty, received_qty, outstanding_qty").paginate(:page => params[:page], :per_page => 100) || []
  end

  def find_receipt
    @receiving = Receiving.find(params[:id])
  end

  def receiving_params
    params.require(:receiving).permit(
      :purchase_order_id, :date, :number, :supplier_id, :note, :received_qty, :purchased_qty, :total, :faktur_date, :consigment_number, :head_office_id, receiving_details_attributes: [:product_size_id, :quantity, :supplier_qty, :_destroy]
    )
  end

  def can_view_receiving
    not_authorized unless current_user.can_view_receiving?
  end

  def can_manage_receiving
    not_authorized unless current_user.can_manage_receiving?
  end
end
