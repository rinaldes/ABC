class StockTransfersController < ApplicationController
  before_filter :can_view_stock_transfer, only: [:index, :show]
  before_filter :can_manage_stock_mutation, only: [:new, :create]
  skip_before_filter :verify_authenticity_token, only: [:destroy]

  def add_product
    @product = Product.find(params[:id])
    @supplier = @product.brand.supplier
    @list_product = ProductDetail.where("warehouse_id=#{(current_user.branch.id rescue Branch.first.id)} AND products.id=#{@product.id}").joins(product_size: [:product])
    respond_to do |format|
      format.js
    end
  end

  def index
    get_paginated_good_transfers
  end

  def new
    @suppliers = Supplier.limit(7)
    @transfer = StockTransfer.new
    @products = Product.select("barcode, barcode").limit(11).order("barcode").map{|product|[product.barcode, product.barcode]}
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
      @transfer = StockTransfer.new(stock_transfer_params.merge(user_id: current_user.id))
      if @transfer.save
        @transfer.generate_details(params)
        flash[:notice] = 'Transfer berhasil ditambahkan'
        redirect_to stock_transfers_path
      else
        @products = Product.select("barcode, barcode").limit(11).order("barcode").map{|product|[product.barcode, product.barcode]}
        flash[:error] = @good_transfer.errors.full_messages.join('<br/>')
        render "new"
      end
  end

  def show
    @good_transfer = StockTransfer.find(params[:id])
    @list_product = StockTransferDetail.where("stock_transfer_id=#{params[:id]}")
    @product_mutation_details = @good_transfer.stock_transfer_details
  end

  def add_brand
    @product = Product.find params[:product_id]
    @list_product = ProductDetail.where(:warehouse_id => params[:origin_branch], product_size_id: @product.product_sizes.map(&:id)).order('id asc')
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @good_transfer = StockTransfer.find(params[:id])
    if @good_transfer.destroy
      get_paginated_good_transfers
    else
      flash[:error] = t(:data_already_in_used)
    end
    respond_to do |format|
      format.js
    end
  end

  private
    def stock_transfer_params
      params.require(:stock_transfer).permit(:date, :no_surat_jalan, :status, :number, :branch_id, :origin_stock, :destination_stock)
    end


    def get_paginated_good_transfers
      conditions = []
      params[:search].each{|param|
        conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'" if param[1].present?
      } if params[:search].present?
      @stock_transfers = StockTransfer.joins(:user, :destination).select("stock_transfers.*, stock_transfers.created_at as st_created_at, office_name as location_name, concat(users.first_name, ' ', users.last_name) AS creator_name").where(conditions.join(' AND '))
        .order(default_order('stock_transfers')).paginate(:page => params[:page], :per_page => 10) || []
    end

    def can_view_stock_transfer
      not_authorized unless current_user.can_view_stock_transfer?
    end

    def can_manage_stock_mutation
      not_authorized unless current_user.can_manage_stock_mutation?
    end
end
