class MinStocksController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  autocomplete :min_stock, :name
  # GET /min_stocks
  # GET /min_stocks.json
  def index
    return not_authorized unless current_user.can_view_min_stock?
    get_paginated_min_stocks
    respond_to do |format|
      format.html{render file: 'min_stocks/index'}
      format.js
    end
  end

  def show
    @min_stock = ProductDetail.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def search
    @min_stocks = ProductDetail.search(params[:search]).uniq.paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      @min_stock = ProductDetail.new
      format.js
    end
  end

  def get_number
    @min_stock_number = Product.number(params)
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

private
  def get_paginated_min_stocks
    conditions = ["(available_qty <= min_stock OR available_qty IS NULL)"]
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].inspect
    } if params[:search].present?
    @min_stocks = ProductDetail.joins(:warehouse, product_size: [:size_detail, product: [:m_class, :colour, brand: :supplier]])
      .select("products.*, product_details.*, brands.name AS brand_name, suppliers.name AS supplier_name, colour_code, m_classes.name AS m_class_name, size_details.size_number AS size_number,
      available_qty, offices.office_name AS warehouse_name")
      .where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' ')).paginate(:page => params[:page], :per_page => 10) || []
  end
end