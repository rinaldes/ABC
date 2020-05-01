class PurchaseRequestsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :get_paginated_purchase_requests, only: [:index, :destroy]
  autocomplete :purchase_request, :number
  before_filter :can_view_pr, only: [:index, :show]
  before_filter :can_manage_pr, only: [:new, :create, :edit, :update, :destroy]

  def index
  end

  def show
    @purchase_request = PurchaseRequest.find(params[:id])
    @supplier = @purchase_request.supplier
    @list_product = ProductDetail
      .where("warehouse_id=#{(current_user.branch.id rescue Branch.first.id)} AND product_size_id IN (SELECT product_size_id FROM purchase_request_details WHERE purchase_request_id=#{@purchase_request.id})")
      .joins(product_size: [:product]).group_by{|pd|pd.product_size.product_id}
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def get_last_number
    render json: {
      number: (('%07d' % (((PurchaseRequest.where("supplier_id=#{params[:supplier_id]} AND extract(YEAR FROM date)=#{Time.now.year}").order("id DESC").limit(1)[0].number.last.to_i rescue 0) +1))))
    }
  end

  def print_to_pdf
    @purchase_request = PurchaseRequest.find params[:id]
    @supplier = @purchase_request.supplier
    html = render_to_string(:layout => "pdf_layout.html") 
    pdf = WickedPdf.new.pdf_from_string(html, :orientation => 'Landscape') 
    send_data(pdf, 
      :filename    => "Purchase Request #{@purchase_request.number}.pdf", 
      :disposition => 'attachment',
    ) 
  end

  def print_to_excel
    p = Axlsx::Package.new
    wb = p.workbook
    wb.add_worksheet(name: "Distributor-#{Time.now.to_i}") do |sheet|
      sheet.add_row ["Code", "Name", "Email", "Phone", "Phone2", "Fax", "Join Date", "Address", "City", "Country", "Postal Code", "Latitude", "Longitude"]
      @distributors.each{|item|
        user = item.user
        sheet.add_row [item.code, (user.usr_name rescue '-'), (user.email rescue '-'), (user.usr_phone_number rescue '-'), (item.cst_phone_2 rescue '-'), item.cst_fax,
          item.cst_join_date, item.cst_address, item.cst_city, (item.cst_country.name rescue '-'), item.cst_postal_code, item.lat, item.lng]
      }
      wb.add_worksheet(:name => "Contact Person") do |sheet2|
        sheet2.add_row ["Distributor Code", "Name", "Email", "Phone 1", "Phone 2", "Position"]
        @distributors.map(&:customer_contacts).each{|customer_contacts|
          customer_contacts.each{|contact|
            sheet2.add_row [contact.customer.code, contact.cstd_name, contact.cstd_email,
              contact.cstd_phone_number.to_i == 0 ? contact.cstd_phone_number : "'#{contact.cstd_phone_number}",
              contact.cstd_phone_number_2.to_i == 0 ? contact.cstd_phone_number_2 : "'#{contact.cstd_phone_number_2}", contact.cstd_position]
          }
        }
      end
    end
  end

  # GET /returns_to_suppliers/1
  

  def new
    time_now = Time.now
    @purchase_request = PurchaseRequest.new date: time_now.strftime('%Y-%m-%d')
    @date = time_now.strftime("%d-%m-%Y")
    load_master
  end

  def create
    @purchase_request = PurchaseRequest.new(
      purchase_request_params.merge(status: params[:commit] == 'Save' ? 'Draft' : PurchaseRequest::WAITING_APPROVAL, requester_id: current_user.id, date: Time.now)
    )
    if @purchase_request.save
      products = params[:good_list].split(',')
      flash[:notice] = 'Purchase Request berhasil ditambahkan'
      redirect_to purchase_requests_path
    else
      flash[:error] = @purchase_request.errors.full_messages
      render "new"
    end
  end

  def update
    @purchase_request = PurchaseRequest.find_by_id(params[:id])
    old_details = @purchase_request.purchase_request_details.map(&:id)
    if @purchase_request.update_attributes(purchase_request_params)
      PurchaseRequestDetail.where(id: old_details).delete_all
      flash[:notice] = t(:successfully_updated)
      redirect_to purchase_requests_path
    else
      flash[:error] = @purchase_request.errors.full_messages
      render "edit"
    end
  end

  def autocomplete_purchase_request
    hash = []
    conditions = ["status IN (#{params[:status]})"]
    conditions << "number like '%#{params[:term]}%'" if params[:term].present?
    conditions << "supplier_id=#{params[:supplier_id]}" if params[:supplier_id].present?
    conditions << "number NOT IN (#{params[:present_pr]})" if params[:present_pr].present?
    @pr = PurchaseRequest.where(conditions.join(' AND ')).order('number')
    @pr.collect do |p|
      hash << {
        "id" => p.id, "label" => p.number, "value" => p.number, pr_date: p.created_at.strftime('%Y-%m-%d'), pr_note: p.note, branch_name: (p.branch.office_name rescue nil),
        quantity: p.purchase_request_details.map(&:approved_qty).compact.sum
      }
    end
    respond_to do |format|
      format.js
      format.json {render json: hash}
    end
  end

  def destroy
    @request = PurchaseRequest.find_by_id(params[:id])
    respond_to do |format|
      if @request.is_waiting_approval? && @request.destroy
        flash.now[:notice] = "PR berhasil dihapus"
      else
        flash.now[:error] = t(:already_in_used)
      end
      format.js
    end
  end

  def edit
    @purchase_request = PurchaseRequest.find_by_id(params[:id])
    @supplier = @purchase_request.supplier
    @list_product = ProductDetail
      .where("warehouse_id=#{(current_user.branch.id rescue Branch.first.id)} AND product_size_id IN (SELECT product_size_id FROM purchase_request_details WHERE purchase_request_id=#{@purchase_request.id})")
      .joins(product_size: [:product]).group_by{|pd|pd.product_size.product_id}
    load_master
  end

  def load_master
    @suppliers = Supplier.select("name, id, address, code").limit(7).order("name")
    @products = Product.select("barcode, id").limit(7).order("barcode").map{|product|[product.barcode, product.id]}
  end

  def get_product
    @product = Product.find_by_barcode(params[:barcode])
    @supplier = @product.brand.supplier
    @list_product = ProductDetail.where("warehouse_id=#{params[:origin_warehouse_id] || current_user.branch_id || Branch.first.id} AND products.id=#{@product.id}")
      .joins(product_size: [:product])
      .sort_by{|product_detail|
      size_number = (product_detail.product_size.size_detail.size_number rescue 1000000) || 1000000
      size_number.to_i == 0 ? size_number : size_number.to_i
    }
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

  def add_product
    @product = Product.find(params[:id])
    @supplier = @product.brand.supplier
    @list_product = ProductDetail.where("warehouse_id=#{(current_user.branch.id rescue params[:branch_id])} AND products.id=#{@product.id}").joins(product_size: [:product])
    respond_to do |format|
      format.js
    end
  end

  def search_in_modal
    search_product_manual
  end

  def search_product_manual
    conditions = []
    conditions << "LOWER(suppliers.code)=LOWER('#{params[:supplier_code]}')" if params[:supplier_code].present?
    conditions << "LOWER(brands.name) LIKE LOWER('%#{params[:brand_name]}%')" if params[:brand_name].present?
    conditions << "LOWER(article) LIKE LOWER('%#{params[:article]}%')" if params[:article].present?
    conditions << "LOWER(m_classes.name) LIKE LOWER('%#{params[:m_class_name]}%')" if params[:m_class_name].present?
    conditions << "barcode NOT IN (#{params[:present_product]})" if params[:present_product].present?
    conditions << "LOWER(barcode) LIKE LOWER('%#{params[:barcode]}%')" if params[:barcode].present?
    @products = Product.where(conditions.join(' AND ')).joins(:m_class, brand: :supplier).paginate(page: params[:page], per_page: 10) || []
  end

  private

    def purchase_request_params
      params.require(:purchase_request).permit(:note, :date, :number, :supplier_id, :branch_id, :status, purchase_request_details_attributes: [:quantity, :product_size_id, :_destroy])
    end

    def get_paginated_purchase_requests
        conditions = []
        params[:search].each{|param|
          conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
        } if params[:search].present?
        @purchase_requests = PurchaseRequest.select("purchase_requests.id, number, date, suppliers.name AS supplier_name, status").joins(:supplier).where(conditions.join(' AND '))
          .order(default_order('purchase_requests')).paginate(page: params[:page], per_page: 10) || []
    end

    def can_view_pr
      not_authorized unless current_user.can_view_pr?
    end

    def can_manage_pr
      not_authorized unless current_user.can_manage_pr?
    end
end
