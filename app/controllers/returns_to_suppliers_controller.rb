class ReturnsToSuppliersController < ApplicationController
  before_filter :can_view_return_to_supplier, only: [:index, :show]
  before_filter :can_manage_return_to_supplier, only: [:new, :create, :edit, :update, :destroy]

  # GET /returns_to_suppliers
  def index
    get_paginated_returns_to_suppliers
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # GET /returns_to_suppliers/1
  def show
    @returns_to_supplier = ReturnsToSupplier.find(params[:id])
    @list_product = ProductDetail.where("warehouse_id=#{(current_user.branch.id rescue Branch.first.id)} AND product_size_id IN (SELECT product_size_id FROM returns_to_supplier_details WHERE returns_to_supplier_id=#{@returns_to_supplier.id})").joins(product_size: [:product]).group_by{|pd|pd.product_size.product_id}
    @receiving = @returns_to_supplier.receiving
    @supplier = @returns_to_supplier.supplier
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def get_receiving
    @receiving = Receiving.find_by_number(params[:name])
    respond_to do |format|
      format.js
    end
  end

  # GET /returns_to_suppliers/new
  def new
    nom = ReturnsToSupplier.count_no(DateTime.now.strftime('%m')).count_not(DateTime.now.strftime('%Y')).count
    @products = Product.select("barcode, barcode").limit(11).order("barcode").map{|product|[product.barcode, product.barcode]}
    @receive_nos = Receiving.select("number, number").limit(11).order("number").map{|product|[product.number, product.number]}
    
    if nom > 0
      nomor = nom + 1
      if nomor.to_s.length < 6
        b = nomor.to_s.length
        while b < 6 do
          nomor = "0" + nomor.to_s
          b += 1
        end
      end
    else
      nomor = "000001"
    end
    #@to_ho = HeadOffice.all.map{|x| [x.name, x.id]}
    @number = "RTS-#{DateTime.now.strftime('%m')}-#{DateTime.now.strftime('%y')}-"+ nomor
    @returns_to_supplier = ReturnsToSupplier.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def print_to_pdf
    @returns_to_supplier = ReturnsToSupplier.find(params[:id])
    @receiving = @returns_to_supplier.receiving
    # tables = [['CODE', 'MERK', 'ARTICLE', 'WARNA', 'DEPARTMENT', 'TOTAL HARGA', 'UKURAN']]
    @supplier = @returns_to_supplier.supplier
    html = render_to_string(:layout => "pdf_layout.html") 
    pdf = WickedPdf.new.pdf_from_string(html, :orientation => 'Landscape') 
    send_data(pdf, 
      :filename    => "Return To Supplier #{@returns_to_supplier.number}.pdf", 
      :disposition => 'attachment',
    ) 
  end

  def print_for_supplier
    @returns_to_supplier = ReturnsToSupplier.find(params[:id])
    @receiving = @returns_to_supplier.receiving
    @supplier = @returns_to_supplier.supplier
    @returns_to_supplier_details = @returns_to_supplier.returns_to_supplier_details
    html = render_to_string(:layout => "pdf_layout.html") 
    pdf = WickedPdf.new.pdf_from_string(html, :orientation => 'Portrait') 
    send_data(pdf, 
      :filename    => "Returns to Supplier Print for Supplier #{@returns_to_supplier.number}.pdf", 
      :disposition => 'attachment',
    )
  end

  # GET /returns_to_suppliers/1/edit
  def edit
    @returns_to_supplier = ReturnsToSupplier.find(params[:id])
    @supplier = @returns_to_supplier.supplier
    @details = @returns_to_supplier.returns_to_supplier_details
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /returns_to_suppliers
  def create
    detail = params[:returns_to_supplier][:returns_to_supplier_details_attributes].values
    @returns_to_supplier = ReturnsToSupplier.new(
      returns_to_supplier_params.merge(
        status: "DELIVERED", quantity: detail.map{|rts|rts["quantity"].to_i}.sum,total: detail.map{|rts|rts["purchase_price"].to_f*rts["quantity"].to_i}.sum,
        receiving_id: (Receiving.find_by_number(params[:receive_no]).id rescue nil)
      )
    )
    respond_to do |format|
      if @returns_to_supplier.save
        params[:return_to_ho].each{|rtho|
          ReturnsToHo.find(rtho).update_attributes(returns_to_supplier_id: @returns_to_supplier.id)
        }
        flash[:notice] = 'Transfer berhasil ditambahkan'
      else
        flash[:error] = @returns_to_supplier.errors.full_messages.join('<br/>')
      end
      format.js
    end
  end

  def get_product
    @product = Product.find_by_barcode(params[:barcode])
    @supplier = @product.brand.supplier
    @list_product = ProductDetail.where("warehouse_id=#{params[:origin_warehouse_id]} AND products.id=#{@product.id}").joins(product_size: [:product, :size_detail])
      .order("size_number")
    respond_to do |format|
      format.js
    end
  end

  # PUT /returns_to_suppliers/1
  # PUT /returns_to_suppliers/1.json
  def update
    @returns_to_supplier = ReturnsToSupplier.find(params[:id])
    unless @returns_to_supplier.status == 'PENDING'
      return redirect_to returns_to_suppliers_url
    end

    respond_to do |format|
      if @returns_to_supplier.update_attributes(params.require(:returns_to_supplier).permit(:note, :status))
        flash.now[:notice] = 'Return to supplier was successfully updated.'
        format.html{redirect_to returns_to_suppliers_url}
      else
        flash.now[:error] = @returns_to_supplier.errors.full_messages
        format.js{render :edit}
      end
    end
  end

  def get_last_number
    render json: {
      number: (('%07d' % (((ReturnsToSupplier.where("supplier_id=#{params[:supplier_id]} AND extract(YEAR FROM date)=#{Time.now.year}").order("id DESC").limit(1)[0].number.last.to_i rescue 0) +1))))
    }
  end

  def add_product_receive
    @receiving = Receiving.find_by_number(params[:number])
    @supplier = @receiving.supplier rescue nil
    @list_product = ProductDetail.where("warehouse_id=#{(current_user.branch.id rescue Branch.first.id)} AND product_size_id IN (SELECT product_size_id FROM receiving_details WHERE receiving_id=#{@receiving.id})").joins(product_size: [:product]).group_by{|pd|pd.product_size.product_id}
    @quantities = {}
    respond_to do |format|
      format.js
    end
  end

  def add_product
    @product = Product.find_by_id(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def mark_as_delivered
    returns_to_supplier = ReturnsToSupplier.find(params[:id])
    respond_to do |format|
      format.html {
        if returns_to_supplier.update_attributes(status: 'Delivered')
          flash[:notice] = "Berhasil, ditandai telah di kirim."
          redirect_to returns_to_suppliers_path
        end
      }
    end
  end

  def returns_to_supplier_params
    params.require(:returns_to_supplier).permit(
      :note, :number, :ongkir, :date, :supplier_id, :head_office_id, :return_type, returns_to_supplier_details_attributes: [:quantity, :product_size_id, :purchase_price]
    )
  end

  def can_view_return_to_supplier
    not_authorized unless current_user.can_view_return_to_supplier?
  end

  def can_manage_return_to_supplier
    not_authorized unless current_user.can_manage_return_to_supplier?
  end

  def search
    @returns_to_suppliers = ReturnsToSupplier.search(params[:search]).uniq.paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      @returns_to_supplier = ReturnsToSupplier.new
      format.js
    end
  end

  private
  def get_paginated_returns_to_suppliers
    conditions = []
    conditions = ["returns_to_suppliers.head_office_id=#{current_user.head_office_id}"] if current_user.branch_id.present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @returns_to_suppliers = ReturnsToSupplier.where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' '))
      .joins("INNER JOIN offices ho ON ho.id=returns_to_suppliers.head_office_id INNER JOIN suppliers sup ON sup.id=supplier_id")
      .select(
        "ho.office_name AS office_name, sup.name AS supplier_name, to_char(date, 'DD-MM-YYYY') AS date, status, number, to_char(quantity, '999') As quantity, total, note, receive_no, returns_to_suppliers.id"
      )
      .paginate(:page => params[:page], :per_page => 10) || []
  end
end
