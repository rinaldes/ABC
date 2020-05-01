class PurchaseOrdersController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy, :approve]
  before_filter :can_view_po, only: [:index, :show]
  before_filter :can_manage_po, only: [:new, :create, :edit, :update, :destroy]
  before_filter :find_po, only: [:edit, :update, :destroy, :approve, :show, :print_to_pdf, :print_for_supplier]

  def show
    @supplier = @purchase_order.supplier
    @list_product = ProductDetail
      .where("warehouse_id=#{(current_user.head_office.id rescue HeadOffice.first.id)} AND product_size_id IN (SELECT product_size_id FROM purchase_order_details WHERE purchase_order_id=#{@purchase_order.id})")
      .joins(product_size: [:product]).group_by{|pd|
      pd.product_size.product_id
    }
    @purchase_order_details = @purchase_order.purchase_order_details
  end

  def print_to_pdf
    @supplier = @purchase_order.supplier
    @purchase_order_details = @purchase_order.purchase_order_details
    html = render_to_string(:layout => "pdf_layout.html") 
    pdf = WickedPdf.new.pdf_from_string(html, orientation: 'Portrait') 
    send_data(pdf, 
      :filename    => "Purchase Order #{@purchase_order.number}.pdf", 
      :disposition => 'attachment',
    ) 
  end

  def print_for_supplier
    @supplier = @purchase_order.supplier
    @purchase_order_details = @purchase_order.purchase_order_details
    html = render_to_string(:layout => "pdf_layout.html") 
    pdf = WickedPdf.new.pdf_from_string(html, :orientation => 'Portrait') 
    send_data(pdf, 
      :filename    => "Purchase Order Print for Supplier #{@purchase_order.number}.pdf", 
      :disposition => 'attachment',
    )
  end

  def continued
  end

  def approve
    if @purchase_order.update_attributes(status: params[:purchase_order][:status])
      purchase_order_detail = PurchaseOrderDetail.where(purchase_order_id: (@purchase_order.id rescue nil))
      purchase_order_detail.each{|pod|
        PurchaseOrderDetail.find_by_product_size_id_and_purchase_order_id(pod['product_size_id'], @purchase_order.id).update_attributes(quantity: params[:pod][pod.product_size_id.to_s]) rescue nil
      }
      @purchase_order.purchase_requests.update_all(status: PurchaseOrder::CLOSED) if params[:purchase_order][:status] == PurchaseOrder::CLOSED
      flash[:notice] = "Successfully #{params[:purchase_order][:status]}"
    end
    get_paginated_purchase_orders
    respond_to do |format|
      format.html{redirect_to purchase_order_url(@purchase_order)}
      format.js
    end
  end

  def add_product_pr
    @purchase_request = PurchaseRequest.find_by_number(params[:number])
    @supplier = @purchase_request.purchase_request_details.first.product_size.product.brand.supplier rescue nil
    respond_to do |format|
      format.js
    end
  end

  def add_product
    @product = Product.find_by_id(params[:id])
  end

  def po_per_supplier
    get_paginated_purchase_orders
    respond_to do |format|
      format.js
    end
  end

  def index
    get_paginated_purchase_orders
  end

  def new
    time_now = Time.now
    @purchase_order = PurchaseOrder.new date: time_now.strftime('%Y-%m-%d')
    load_master
  end

  def get_size
    @product = Product.find_by_id(params[:product_id])
    @list_product = ProductDetail.where("warehouse_id=#{current_user.branch.id} AND products.id=#{@product.id}").joins(product_size: [:product])
    respond_to do |format|
      format.js
    end
  end

  def get_last_number
    render json: {
      number: (('%07d' % (((PurchaseOrder.where("supplier_id=#{params[:supplier_id]} AND extract(YEAR FROM date)=#{Time.now.year}").order("id DESC").limit(1)[0].number.last.to_i rescue 0) +1))))
    }
  end

  def create
    values_details = params[:purchase_order][:purchase_order_details_attributes].values
    @order = PurchaseOrder.new(purchase_order_params.merge(status: PurchaseRequest::WAITING_APPROVAL, date: Time.now, total_qty: values_details.map{|po|po[:quantity].to_i}.sum,
      grand_total: values_details.map{|po|ProductSize.find(po[:product_size_id]).product.cost_of_products.to_f*po[:quantity].to_i}.sum))
    if @order.save
      if params[:purchase_request_list].present? && params[:purchase_request_list] != '-'
        PurchaseRequest.where("number IN ('#{params[:purchase_request_list].gsub(',', "','")}')").update_all("status='#{PurchaseOrder::APPROVED}', purchase_order_id=#{@order.id}")
        values_details.each{|a|
          PurchaseRequestDetail.find_by_id(a['purchase_request_detail_id']).update_attributes(approved_qty: a['quantity']) rescue nil
        }
      end
      flash[:notice] = t(:successfully_created)
      redirect_to purchase_orders_path
    else
      flash[:error] = @order.errors.full_messages.join('<br/>')
      render "new"
    end
  end

  def edit
    @supplier = @purchase_order.supplier
    @list_product = ProductDetail.where("warehouse_id=#{@purchase_order.head_office_id} AND product_size_id IN (SELECT product_size_id FROM purchase_order_details WHERE purchase_order_id=#{@purchase_order.id})")
      .joins(product_size: [:product]).group_by{|pd|pd.product_size.product_id}
  end

  def destroy
    respond_to do |format|
      if @purchase_order.is_waiting_approval? && @purchase_order.destroy
        get_paginated_purchase_orders
        flash.now[:notice] = "PO berhasil dihapus"
      else
        flash.now[:error] = t(:already_in_used)
      end
      format.js
    end
  end

  def load_master
    load_supplier
    @products = Product.select("barcode, id").limit(7).order("barcode").map{|product|[product.barcode, product.id]}
    @requests = PurchaseRequest.select("number, id").limit(7).order("number").map{|request|[request.number, request.id]}
  end

  def get_purchase_request
    @request = PurchaseRequest.find_by_number(params[:number])
    respond_to do |format|
      format.js
    end
  end

  def get_supplier
    @supplier = Supplier.find_by_name(params[:name])
    respond_to do |format|
      format.js
    end
  end

  def autocomplete_purchase_order
    hash = []
    conditions = []
    conditions << "LOWER(number) like LOWER('%#{params[:term]}%')" if params[:term].present?
    conditions << "supplier_id=#{params[:supplier_id]}" if params[:supplier_id].present?
    conditions << "status IN (#{params[:status]})" if params[:status].present?
    @po = PurchaseOrder.where(conditions.join(' AND ')).limit(200).order('number')
    @po.collect do |p|
      supplier = p.supplier
      hash << {
        id: p.id, label: p.number, "value" => p.number, date: p.date, po_note: p.note, supplier_code: (supplier.code rescue ''), supplier_name: (supplier.name rescue ''), address: (supplier.address rescue '')
      }
    end
    respond_to do |format|
      format.js
      format.json {render json: hash}
    end
  end

  def update
    old_details = @purchase_order.purchase_order_details.map(&:id)
    if @purchase_order.update_attributes(purchase_order_params)
      PurchaseOrderDetail.where(id: old_details).delete_all
      flash[:notice] = t(:successfully_updated)
      redirect_to purchase_orders_path
    else
      flash[:error] = @purchase_order.errors.full_messages
      render "edit"
    end
  end

  private
    def purchase_order_params
      params.require(:purchase_order).permit(:date, :number, :supplier_id, :note, :number, :head_office_id, purchase_order_details_attributes: [:quantity, :product_size_id])
    end

    def get_paginated_purchase_orders
      conditions = []
      params[:search].each{|param|
        conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
      } if params[:search].present?
      @purchase_orders = PurchaseOrder.select("purchase_orders.id, number, date, suppliers.name AS supplier_name, status, grand_total, total_qty, note").where(conditions.join(' AND ')).joins(:supplier)
        .order(default_order('purchase_orders')).paginate(page: params[:page], per_page: 10) || []
    end

    def can_view_po
      not_authorized unless current_user.can_view_po?
    end

    def can_manage_po
      not_authorized unless current_user.can_manage_po?
    end

    def find_po
      @purchase_order = PurchaseOrder.find params[:id]
    end
end
