class SellingPricesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :can_view_selling_price, only: [:index, :show]
  before_filter :can_manage_selling_price, only: [:new, :create]

  def index
    get_paginated_selling_prices
    respond_to do |format|
      format.html
      format.js
      format.xls
      if(params[:a] == "a")
        format.csv { send_data SellingPrice.to_csv2 }
      else
        format.csv { send_data @selling_prices.to_csv }
      end
    end
  end

  def fitur_filter
    if params[:fitur_filter] == "current"
      conditions = ["end_date > now()"]
      @selling_prices = SellingPriceDetail.select("selling_prices.*, selling_price_details.*, products.description, offices.office_name, article, barcode").where(conditions.join(' AND '))
       .order(default_order('selling_prices')).joins(selling_price: [:product, :office]).paginate(page: params[:page], :per_page => 100) || []
    elsif params[:fitur_filter] == "history"
      conditions = ["end_date < now()"]
      @selling_prices = SellingPriceDetail.select("selling_prices.*, selling_price_details.*, products.description, offices.office_name, article, barcode").where(conditions.join(' AND '))
       .order(default_order('selling_prices')).joins(selling_price: [:product, :office]).paginate(page: params[:page], :per_page => 100) || []
    else
      @selling_prices = SellingPriceDetail.select("selling_prices.*, selling_price_details.*, products.description, offices.office_name, article, barcode").all
     .order(default_order('selling_prices')).joins(selling_price: [:product, :office]).paginate(page: params[:page], :per_page => 100) || []
    end
  end

  def import
    begin
      import_result = SellingPrice.import(params[:file])
      if params[:file].present?
        if import_result[:error] == 1
          flash[:error] = import_result[:message]
        else
          flash[:notice] = import_result[:message]
        end
      else
        flash[:error] = "Please attach CSV File"
      end
    rescue => e
       flash[:error] = "Failed import. Please recheck CSV File"
    end
    redirect_to selling_prices_path
  end

  def show
    @selling_price = SellingPrice.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def destroy
    @selling_price = SellingPrice.find(params[:id])
    @selling_price.destroy
    get_paginated_selling_prices
    respond_to do |format|
      format.js
    end
  end

  def search
    @selling_price = SellingPrice.search(params[:search]).uniq.paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      @selling_price = SellingPrice.new
      format.js
    end
  end

  def search_in_modal
    search_product_manual
  end

  def search_product_manual
    conditions = []
    conditions << "LOWER(suppliers.code) LIKE LOWER('%#{params[:supplier_code]}%')" if params[:supplier_code].present?
    conditions << "LOWER(article) LIKE LOWER('%#{params[:article]}%')" if params[:article].present?
    conditions << "LOWER(barcode) LIKE LOWER('%#{params[:barcode]}%')" if params[:barcode].present?
    conditions << "LOWER(description) LIKE LOWER('%#{params[:description]}%')" if params[:description].present?
    conditions << "LOWER(brands.name) LIKE LOWER('%#{params[:brand]}%')" if params[:brand].present?
    @products = Product.where(conditions.join(' AND '))
      .joins("LEFT JOIN product_suppliers ON products.id=product_suppliers.product_id LEFT JOIN contact_people ON product_suppliers.contact_person_id=contact_people.id LEFT JOIN suppliers ON contact_people.supplier_id=suppliers.id").paginate(page: params[:page], :per_page => 10) || []
    @offices = params[:offices].split(",") if params[:offices].present?
  end

  def get_number
    @selling_price = SellingPrice.number(params)
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
  def selling_price_params
    params.require(:selling_price).permit(:start_date, :end_date, :product_id ,:margin, :hpp, :hpp_2, :hpp_average, :dpp, :ppn_in, :ppn_out, :office_id, :margin_amount, :margin_percent, :selling_price,
      :selling_price_middle, :selling_price_high)
  end

  def get_paginated_selling_prices
    conditions = []
    conditions << "end_date > now()" if params[:fitur_filter] == "current"
    conditions << "end_date < now()" if params[:fitur_filter] == "history"
    conditions << "office_id=#{current_user.branch_id}" if current_user.branch_id.present?

    params[:search].each{|param|
      if param[0] == 'barcode' && param[1].include?(' ')
        conditions << "barcode IN ('#{param[1].split( ).join("','")}')"
      else
        conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
      end
    } if params[:search].present?
    if (params[:format].present? && %w(csv xls).include?(params[:format]))
      @selling_prices = SellingPrice.select("selling_prices.id as id,start_date, end_date, products.selling_price as selling_price, products.purchase_price as purchase_price, products.margin_percent as margin_percent, article, barcode, brands.name as brand_name").where(conditions.join(' AND '))
        .order(default_order('selling_prices')).joins(product: :brand)
    else
      @selling_prices = SellingPrice.select("selling_prices.id as id,start_date, end_date, products.selling_price as selling_price, products.purchase_price as purchase_price, products.margin_percent as margin_percent, article, barcode, brands.name as brand_name").where(conditions.join(' AND '))
        .order(default_order('selling_prices')).joins(product: :brand).paginate(page: params[:page], :per_page => 100) || []
   end
  end

  def can_view_selling_price
    not_authorized unless current_user.can_view_product?
  end

  def can_manage_selling_price
    not_authorized unless current_user.can_manage_product?
  end

end
