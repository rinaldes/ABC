class StockOpnamesController < ApplicationController
  before_filter :can_view_stock_opname, only: [:index, :show]
  before_filter :can_manage_stock_opname, only: [:new, :create]

  def update
    @stock_opname = StockOpname.find params[:id]
    @stock_opname.update_attributes(status: 'COMPLETED')
    @stock_opname.stock_opname_details.each{|sod|
      #sod.diff
      pd = ProductDetail.find_by_product_size_id_and_warehouse_id(sod.product_size_id, @stock_opname.office_id)
      ProductMutationHistory.create product_detail_id: ProductDetail.find_by_product_size_id_and_warehouse_id(sod.product_size_id, @stock_opname.office_id).id, old_quantity: pd.available_qty,
        moved_quantity: sod.qty_actual.to_i-sod.qty_virtual.to_i, new_quantity: sod.qty_actual, mutation_type: 'StockOpname', quantity_type: 'available_qty', product_mutation_detail_id: sod.id
      pd.update_attributes(available_qty: sod.qty_actual)
    }
    redirect_to stock_opname_url(@stock_opname)
  end

  def edit
    @stock_opname = StockOpname.find params[:id]
    @stock_opname_details = @stock_opname.stock_opname_details.order("size_details.size_number").joins(product_size: :size_detail)
    @office_id = @stock_opname.office_id
    @office_class = @stock_opname.office.class.to_s
  end

  def index
    conditions = []
    conditions << "office_id=#{current_user.office_id}" if current_user.office_id.present?
    @stock_opnames = StockOpname.where(conditions.join(' AND ')).order("id DESC").paginate(:page => params[:page], :per_page => 5) || []
    respond_to do |format|
      format.html
    end
  end

  def new
    @cabang = Branch.all.map{|x| [x.office_name, x.id]}
    @office_id = current_user.office_id
    @stock_opname = StockOpname.find_by_id(params[:id]) || StockOpname.new
    respond_to do |format|
      format.html
    end
  end

  def end_stock_opname_data
    @stock_opname = StockOpname.where(office_id: params[:office_id], status: 'ONPROCESS').first
    product_detail = ProductDetail.where("warehouse_id=#{params[:office_id]}").select("available_qty+allocated_qty+freezed_qty+rejected_qty+defect_qty+online_qty AS qty")

    if @stock_opname.office.class.to_s == 'Branch'
      mutation_out_conditions = ["origin_warehouse_id=#{params[:office_id]} AND type='GoodTransfer'"]
      mutation_out_conditions << "product_mutations.created_at > '#{@stock_opname.start_date}'" if @stock_opname.present?

      retur_conditions = ["origin_warehouse_id=#{params[:office_id]} AND type='ReturnsToHo'"]
      retur_conditions << "product_mutations.created_at > '#{@stock_opname.start_date}'" if @stock_opname.present?

      mutation_in_conditions = ["destination_warehouse_id=#{params[:office_id]} AND status='#{ProductMutation::RECEIVED}' AND type='GoodTransfer'"]
      mutation_in_conditions << "product_mutations.created_at > '#{@stock_opname.start_date}'" if @stock_opname.present?

      sold_conditions = ["store_id=#{params[:office_id]} AND status='FINISHED'"]
      sold_conditions << "sales.created_at > '#{@stock_opname.start_date}'" if @stock_opname.present?

      receive_transfer_conditions = ["destination_warehouse_id=#{params[:office_id]} AND status='#{ProductMutation::RECEIVED}' AND type='PurchaseTransfer'"]
      receive_transfer_conditions << "product_mutations.created_at > '#{@stock_opname.start_date}'" if @stock_opname.present?

      @stock_opname.update_attributes(
        sold: SalesDetail.where(sold_conditions.join(' AND ')).joins(:sale).map(&:quantity).compact.sum,
        received_from_transfer: ProductMutationDetail.where(receive_transfer_conditions.join(' AND ')).joins(:product_mutation).map(&:quantity).compact.sum,
        mutation_in: ProductMutationDetail.where(mutation_in_conditions.join(' AND ')).joins(:product_mutation).map(&:quantity).compact.sum,
        mutation_out: ProductMutationDetail.where(mutation_out_conditions.join(' AND ')).joins(:product_mutation).map(&:quantity).compact.sum,
        last_stock: product_detail.map(&:qty).compact.sum, retur: ProductMutationDetail.where(retur_conditions.join(' AND ')).joins(:product_mutation).map(&:quantity).compact.sum, end_date: Time.now
      )
    else
      retur_conditions = ["head_office_id=#{params[:office_id]}"]
      retur_conditions << "returns_to_suppliers.created_at > '#{@stock_opname.start_date}'" if @stock_opname.present?

      mutation_in_conditions = ["destination_warehouse_id=#{params[:office_id]} AND status='#{ProductMutation::RECEIVED}' AND type IN ('ReturnsToHo', 'GoodTransfer')"]
      mutation_in_conditions << "product_mutations.created_at > '#{@stock_opname.start_date}'" if @stock_opname.present?

      mutation_out_conditions = ["origin_warehouse_id=#{params[:office_id]} AND type IN ('PurchaseTransfer', 'GoodTransfer')"]
      mutation_out_conditions << "product_mutations.created_at > '#{@stock_opname.start_date}'" if @stock_opname.present?

      receiving_conditions = ["head_office_id=#{params[:office_id]}"]
      receiving_conditions << "receivings.created_at > '#{@stock_opname.start_date}'" if @stock_opname.present?

      @stock_opname.update_attributes(
        received_from_transfer: ReceivingDetail.where(receiving_conditions.join(' AND ')).joins(:receiving).map(&:quantity).compact.sum,
        mutation_in: ProductMutationDetail.where(mutation_in_conditions.join(' AND ')).joins(:product_mutation).map(&:quantity).compact.sum,
        mutation_out: ProductMutationDetail.where(mutation_out_conditions.join(' AND ')).joins(:product_mutation).map(&:quantity).compact.sum,
        last_stock: product_detail.map(&:qty).compact.sum, retur: ReturnsToSupplier.where(retur_conditions.join(' AND ')).map(&:quantity).compact.sum, end_date: Time.now
      )
    end
  end

  def start_stock_opname_data
    @stock_opname = StockOpname.where(office_id: params[:office_id], status: 'ONPROCESS')
    if @stock_opname.blank?
      no = StockOpname.number
      product_details = ProductDetail.where("warehouse_id=#{params[:office_id]} AND available_qty+allocated_qty+freezed_qty+rejected_qty+defect_qty+online_qty > 0")
        .select("available_qty+allocated_qty+freezed_qty+rejected_qty+defect_qty+online_qty AS qty, id, product_size_id")

      @stock_opname = StockOpname.new office_id: params[:office_id], status: 'ONPROCESS', inspector_id: current_user.id, start_date: Time.now, system_stock: product_details.map(&:qty).compact.sum,
        opname_number: "OP/#{romanian_month} - #{('000000'.last(6-no.to_s.length)) + no.to_s}"
      if @stock_opname.save
        product_details.each{|product_detail|
          @stock_opname.stock_opname_details.create system_stock: product_detail.qty, product_size_id: product_detail.product_size_id
        }
      end
    end
  end

  def select_stock_opname_data
    @stock_opname = StockOpname.find_by_office_id_and_status(params[:office_id], 'ONPROCESS')
    @office_id = current_user.office_id || params[:office_id]
  end

  def get_quantity_data
    @product = Product.find_by_id(params[:product_id])
    @product_details = ProductDetail.where("warehouse_id=#{params[:warehouse_id]} AND products.id=#{params[:product_id]}").joins(product_size: [:product, :size_detail])
      .order("size_number")
    respond_to do |format|
      format.js
    end
  end

  def show
    @stock_opname = StockOpname.find(params[:id])
    @stock_opname_details = StockOpnameDetail.where("stock_opname_id = ?", @stock_opname.id)

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def create
    @stock_opname = StockOpname.new(stock_opname_params)
    respond_to do |format|
      if @stock_opname.save
        flash.now[:notice] = 'Stock opname berhasil ditambahkan'
        format.html { redirect_to stock_opnames_url}
      else
        @cabang = current_user.branches.map{|x| [x.name, x.id]}
        flash.now[:error] = @stock_opname.errors.full_messages
        format.html { render "new" }
      end
    end
  end

  def form_import_packing_list

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def add_by_barcode
    @goods_size = Product.find_by_barcode(params[:barcode])
    respond_to do |format|
      format.js
    end
  end

  def import_packing_list
    @data = StockOpname.import(params)
    @cabang = current_user.branches.map{|x| [x.name, x.id]}
    ho = current_user.head_offices.map{|x| [x.name, x.id]}
    ho.each do |x|
      @cabang << x
    end
    no = StockOpname.number
    number = "OP/#{romanian_month} - #{('000000'.last(6-no.to_s.length)) + no.to_s }"
    @stock_opname = StockOpname.new opname_number: number

    render :new

  end

  def to_excel_example
    respond_to do |format|
      format.xls {render 'stock_opnames/to_excel_example.xls.writeexcel'}
    end
  end

  def buka_gudang
    if params[:cabang].present?
      @store = Store.where(branch_id: params[:cabang]).map{|x| [x.name, x.id]}
    else
      @store = Store.where(head_office_id: params[:head_office]).map{|x| [x.name, x.id]}
    end
    respond_to do |format|
      format.js
    end
  end

  def get_stock
    goods_size = Product.find(params[:id])
    last_stock = goods_size.goods_details.sum(:quantity) rescue goods_size.goods_details.map{|x| x.goods_quantity_logs.sum(:new_quantity) }.sum
    respond_to do |format|
      format.json {render json: {
        last_stock: last_stock
      }}
    end
  end

  def search
    conditions = []
    conditions << "stock_opnames.date >= DATE('#{params[:start_date]}')" if params[:start_date].present?
    conditions << "stock_opnames.date <= DATE('#{params[:end_date]}')" if params[:end_date].present?
    conditions << "stock_opnames.opname_number = '#{params[:number]}'" if params[:number].present?
    conditions << "stock_opnames.store_id = #{params[:store_id]}" if params[:store_id].present?
    conditions << "stock_opnames.inspector_id = #{params[:inspector_id]}" if params[:inspector_id].present?
    conditions << "stock_opname_details.explanation = '#{params[:explanation]}'" if params[:explanation].present?
    @stock_opnames = StockOpname.joins(:stock_opname_details).where(conditions.join(' and ')).order("id DESC").paginate(:page => params[:page], :per_page => 5) || []
    respond_to do |format|
      format.js
    end
  end

   def stock_opname_params
    params.require(:stock_opname).permit(
      :date, :opname_number, :inspector_id, :branch_id, stock_opname_details_attributes: [:product_size_id, :qty_virtual, :qty_actual, :explanation]
    )
  end

  def can_view_stock_opname
    not_authorized unless current_user.can_view_stock_opname?
  end

  def can_manage_stock_opname
    not_authorized unless current_user.can_manage_stock_opname?
  end
end
