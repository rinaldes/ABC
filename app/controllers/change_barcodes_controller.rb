class ChangeBarcodesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  autocomplete :product, :article
#  skip_before_filter :authenticate_user!, only: :stock
  before_filter :can_view_product, only: [:index, :show]
  before_filter :can_manage_product, only: [:new, :create, :update]

  def transaction_history
    @product = Product.find_by_barcode params[:barcode]
    @sales = SalesDetail.where("product_sizes.product_id IN (SELECT id FROM products WHERE barcode='#{params[:barcode]}')").joins(product_size: :product)
    respond_to do |format|
      format.js
    end
  end

  def import
    if params[:commit] == 'Import Barcode Size'
      respond_to do |format|
#        import_result = Product.import_barcode_size(params[:file])
        format.csv { send_data Product.import_barcode_size(params[:file]) }
        format.html{ send_data Product.import_barcode_size(params[:file]) }
      end
    elsif params[:commit] == 'Perbaikan Article'
      import_result = Product.import_perbaikan_article(params[:file])
    else
#       import_result = Product.import(params[:file])
      respond_to do |format|
      format.html{ send_data Product.import(params[:file]) }
      end
#      if %w(text/csv application/vnd.ms-excel).include?params[:file].content_type
 #       if import_result[:error] == 1
  #        flash[:error] = import_result[:message]
   #     else
    #      flash[:notice] = import_result[:message]
     #   end
      #else
       # flash[:error] = "Please attach CSV File"
      #end
#      redirect_to products_path
    end
  end

  def add_branch
  end

  def add_m_class
    @first_m_class = MClass.find_by_parent_id(MClass.find_by_name(params[:parent_id]).id) rescue nil
    @m_classes = MClass.where("parent_id=#{MClass.find_by_name(params[:parent_id]).id}") rescue nil
  end

  def show
    @product = Product.find params[:id]
    load_master_data_for_goods
    @m_class = MClass.find_by_id(@product.m_class_id)
    @colour_code = ''
    @size = @product.size rescue ''
    @size_details = @size.sorted_size_details
    @branch_prices = BranchPrice.where("product_id=#{@product.id}")
    @total = 0
    @product_details = ProductDetail.joins(:product_size).where("product_sizes.product_id=#{@product.id} AND warehouse_id IN (#{current_user.current_offices.map(&:id).push(0).join(', ')})")
      .group_by(&:product_size_id)
    @can_manage_product = current_user.can_manage_product?
  end

  # GET /goods
  def index
    get_paginated_products
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.xls
      if(params[:a] == "a")
        format.csv { send_data @products.to_csv2 }
      else
        format.csv { send_data @products.to_csv }
      end
    end
  end

  # GET /goods/add
  def add
    @goods = Product.new
    load_master_data_for_goods
    @units = Unit.all
    @branches = Branch.all
    @brands = Brand.select(:name)
    respond_to do |format|
      format.html
    end
  end

  def detail_good
    @goods = Product.find(params[:id])
    @user_branches =  Office.all.map{|x| [x.name, x.id]}
    @user_branches << ["Global", "Global"]
    @sizes = Size.all
    @size_details = SizeDetail.all
    @colours = Colour.all
    @stores = Store.all
    @units = Unit.all
    @branches = Branch.all
  end

  def detail_goods_photo
    @goods = Product.find(params[:id])
     respond_to do |format|
      format.js
    end
  end

  def update_goods_photo
    @goods = Product.find(params[:id])
    respond_to do |format|
      if @goods.update_attributes(params[:product]) #&& require_update_discount
        if !params[:image_url].blank?
          @goods.image.clear
          @goods.image = URI.parse(params[:image_url])
          @goods.save!
        end
        # flash.now[:notice] = 'Product photo was successfully updated.'
        format.html{render 'edit'}
      else
        format.html{redirect_to products_url}
      end
    end    
  end

  def get_sales_data
    conditions = ["quantity > 0 AND goods.barcode='#{params[:barcode]}'"]
    conditions << "sales_details.created_at >= '#{params[:start_date].to_date.strftime('%Y-%m-%d')}'" if params[:start_date].present?
    conditions << "sales_details.created_at <= '#{params[:end_date].to_date.strftime('%Y-%m-%d')}'" if params[:end_date].present?
    @sales_details = SalesDetail.joins(goods_size: [:size_detail, goods: [brand: [:supplier]]], sale: [:user, store: [:branch]])
    .where(conditions.join(' AND ')).select('sales_details.created_at, bill_number, first_name, last_name, size_number, quantity, price,
        discount, price_after_discount, goods.barcode AS barcode')
    @sales_details = @sales_details.paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      format.js
    end
  end

  def scan_barcode
    if params[:barcode].present?
      goods = Product.find_by_barcode(params[:barcode])
    else
      conditions = []
      conditions << "brands.name='#{params[:brand]}'" if params[:brand].present?
      conditions << "colours.name='#{params[:colour]}'" if params[:colour].present?
      conditions << "article='#{params[:article]}'" if params[:article].present?
      goods = Product.joins(:brand, :colour).last(conditions: [conditions.join(' AND ')])
    end
    brand = goods.brand

    goods_discount = goods.discounts.actives.last
    # if goods_discount.present? && goods_discount.discount_type != Discount::TidakAdaDiskon#next time TidakAdaDiskon should be deleted
    disc = goods_discount
    # else
    # disc = brand.discounts.actives.last
    brand_discount_percent = goods.brand.discounts.last.percent rescue '' #disc.id rescue ''
    # end

    render json: {
      id: (goods.id rescue 0), type: (goods.type.name), brand: (brand.name rescue ''), article: goods.article, barcode: goods.barcode,
      brand_percent: brand_discount_percent, colour: (goods.colour.name rescue ''), size: (goods.size.description rescue ''),
      status: goods.status, path_image: (goods.image.url rescue ''), unit_id: goods.unit_id, percentage_price: goods.percentage_price,
      supplier: (brand.supplier.name rescue ''), disc_type: (disc.discount_type rescue 'tidak ada diskon'),
      cost_of_goods: goods.cost_of_goods, purchase_price: goods.cost_of_goods, selling_price: goods.selling_price,
      discount_percent: (disc.percent rescue ""),
      start_date: ((disc.start_date.strftime("%d-%m-%Y") if disc.discount_type!=Discount::TidakAdaDiskon) rescue ''), end_date: (disc.end_date.strftime("%d-%m-%Y") rescue ''),
      netto: ((goods.netto - (disc.percent/100 * goods.netto)) rescue ''), last_update_cost: goods.updated_at.strftime("%d-%m-%Y"),
      last_update_sell: goods.updated_at.strftime("%d-%m-%Y"), brand_discount: (brand_discount.last.percent rescue "")
    }
  end
  
  def get_pmb_goods_detail
    if params[:barcode].present?
      goods = Product.find_by_barcode(params[:barcode]) 
      result = {error:1}
      return render json: result if goods.nil?
      
    else
      result = {error:1}
      return render json: result
      #      conditions = []
      #      conditions << "brands.name='#{params[:brand]}'" if params[:brand].present?
      #      conditions << "colours.name='#{params[:colour]}'" if params[:colour].present?
      #      conditions << "article='#{params[:article]}'" if params[:article].present?
      #      goods = Product.joins(:brand, :colour).last(conditions: [conditions.join(' AND ')])
    end
    result = goods.get_pmb_goods_detail

    render json: result
  end

  def get_goods_detail
    if params[:colour].present?
      goods = Product.where(:article => params[:article], :colour_id => params[:colour], :status => params[:status]) 
      result = {error:1}
      return render json: result if goods.first.nil?
      
    else
      result = {error:1}
      return render json: result
      #      conditions = []
      #      conditions << "brands.name='#{params[:brand]}'" if params[:brand].present?
      #      conditions << "colours.name='#{params[:colour]}'" if params[:colour].present?
      #      conditions << "article='#{params[:article]}'" if params[:article].present?
      #      goods = Product.joins(:brand, :colour).last(conditions: [conditions.join(' AND ')])
    end
    result = goods.first.get_pmb_goods_detail

    render json: result    
  end

  def  get_goods_detail_by_colour
    if params[:colour].present?
      goods = Product.where(:article => params[:article], :colour_id => params[:colour]) 
      result = {error:1}
      return render json: result if goods.first.nil?
      
    else
      result = {error:1}
      return render json: result
      #      conditions = []
      #      conditions << "brands.name='#{params[:brand]}'" if params[:brand].present?
      #      conditions << "colours.name='#{params[:colour]}'" if params[:colour].present?
      #      conditions << "article='#{params[:article]}'" if params[:article].present?
      #      goods = Product.joins(:brand, :colour).last(conditions: [conditions.join(' AND ')])
    end
    result = goods.first.get_pmb_goods_detail

    render json: result    
  end

  def get_pmb_data
    goods = Product.find(params[:id])
    data = {}
    goods_sizes = goods.goods_sizes
    if goods_sizes.present?
      goods_sizes.each do |goods_size|
        goods_receipt_details = goods_size.goods_receipt_details
        if !goods_receipt_details.blank?
          goods_receipt_details.each_with_index do |goods_receipt_detail, i|
            date = goods_receipt_detail.goods_receipt.received_date
            date_split = date.split("-")
            date = "#{date_split[1]}-#{date_split[2]}-#{date_split[0]}"
            if(data[goods_receipt_detail.goods_receipt.code].blank?)
              data[goods_receipt_detail.goods_receipt.code] = {}
            end
            if(data[goods_receipt_detail.goods_receipt.code]["data"].blank?)
              data[goods_receipt_detail.goods_receipt.code]["data"] = {}
            end
            data[goods_receipt_detail.goods_receipt.code]["data"]["#{goods_size.size_detail.size_number}"] = {"qty" => goods_receipt_detail.qty, "pbd" => goods_receipt_detail.price_before_discount, "td" => goods_receipt_detail.total_discount, "pad" => goods_receipt_detail.price_after_discount}
            data[goods_receipt_detail.goods_receipt.code]["name"] = goods_receipt_detail.goods_receipt.code
            data[goods_receipt_detail.goods_receipt.code]["received_date"] = date
            data[goods_receipt_detail.goods_receipt.code]["key"] = data[goods_receipt_detail.goods_receipt.code]["data"].keys
          end
        end
      end
    end
    data = data.sort_by{|x| x[0]}.reverse!
    key = data.map{|x| x[0]}

    respond_to do |format|
      format.json {
        render json: {
          data: data,
          key: key
        }
      }
    end
  end

  def filter_goods
    @exported_goods = Product.goods_filter params
    @_goods = @exported_goods.paginate(:page => params[:page], :per_page => 10) || []

    respond_to do |format|
      format.js
    end
  end

  def history_pmb
    goods = Product.find(params[:search_id])
    data = {}
    goods_sizes = goods.goods_sizes
    if goods_sizes.present?
      goods_sizes.each do |goods_size|
        goods_receipt_details = goods_size.goods_receipt_details
        if !goods_receipt_details.blank?
          goods_receipt_details.each_with_index do |goods_receipt_detail, i|
            date = goods_receipt_detail.goods_receipt.received_date
            date_split = date.split("-")
            date = "#{date_split[1]}-#{date_split[2]}-#{date_split[0]}"
            if(DateTime.parse(date) >= DateTime.parse(params[:product_receipt_start_date]) &&  DateTime.parse(date) <= DateTime.parse(params[:product_receipt_end_date]))
              if(data[goods_receipt_detail.goods_receipt.code].blank?)
                data[goods_receipt_detail.goods_receipt.code] = {}
              end
              if(data[goods_receipt_detail.goods_receipt.code]["data"].blank?)
                data[goods_receipt_detail.goods_receipt.code]["data"] = {}
              end
              data[goods_receipt_detail.goods_receipt.code]["data"]["#{goods_size.size_detail.size_number}"] = {"qty" => goods_receipt_detail.qty, "pbd" => goods_receipt_detail.price_before_discount, "td" => goods_receipt_detail.total_discount, "pad" => goods_receipt_detail.price_after_discount}
              data[goods_receipt_detail.goods_receipt.code]["name"] = goods_receipt_detail.goods_receipt.code
              data[goods_receipt_detail.goods_receipt.code]["received_date"] = date
              data[goods_receipt_detail.goods_receipt.code]["key"] = data[goods_receipt_detail.goods_receipt.code]["data"].keys
            end
          end
        end
      end
    end
    data = data.sort_by{|x| x[0]}.reverse!
    key = data.map{|x| x[0]}

    respond_to do |format|
      format.json {
        render json: {
          data: data,
          key: key
        }
      }
    end
  end

  def insert_price_log(params, old_price, new_price, code)
    price_log = PriceLog.new(:product_id => params, :old_price => old_price, :new_price => new_price, :code => code)
    price_log.save
  end

  def update_goods_stock
    @goods = Product.find(params[:id])

    params[:product][:type_id] = Type.find_by_name(params[:product][:type_id]).id rescue 0
    params[:product][:brand_id] = Brand.find_by_name(params[:product][:brand_id]).id rescue 0
    params[:product][:colour_id] = Colour.find_by_name(params[:product][:colour_id]).id rescue 0
    params[:product][:size_id] = Size.find_by_description(params[:product][:size_id]).id rescue 0
    params[:product][:old_selling_price] = @goods.selling_price if params[:product][:selling_price].gsub(/\D/, '') != @goods.selling_price
    params[:product][:cost_of_goods] = params[:product][:cost_of_goods].gsub(/\D/, '')
    params[:product][:purchase_price] = params[:product][:purchase_price] #.gsub(/\D/, '')
    params[:product][:selling_price] = params[:product][:selling_price].gsub(/\D/, '')
    params[:product][:netto] = params[:product][:netto].gsub(/\D/, '')
    params[:product][:netto] = params[:product][:netto].gsub(/\D/, '')

    params[:product].delete :brand_id
    params[:product].delete :colour_id
    params[:product].delete :barcode

    # require_update_discount = @goods.discounts.new
# percent: params[:discount_percent]) if params[:discount].present? && [Discount::Normal, Discount::Fiftyfifty, Discount::TanggungSupplier, Discount::TidakAdaDiskon].include?(params[:discount][:discount_type]

    respond_to do |format|
      if @goods.update_attributes(params[:product]) #&& require_update_discount
        if !params[:image_url].blank?
          @goods.image.clear
          @goods.image = URI.parse(params[:image_url])
          @goods.save!
        end
        @goods.set_price_branches(params)
        flash.now[:notice] = 'Product stock was successfully updated.'
        format.html  {redirect_to detail_good_goods_path(@goods.id) }
      else
         # @goods = Product.find(params[:id])
    @user_branches =  Office.all.map{|x| [x.name, x.id]}
    @user_branches << ["Global", "Global"]
    @sizes = Size.all
    @size_details = SizeDetail.all
    @colours = Colour.all
    @stores = Store.all
    @units = Unit.all
    @branches = Branch.all
        puts ap  flash.now[:error] = @goods.errors.full_messages
        format.html  { render :detail_good }
      end
    end
  end

  def destroy
    @product = Product.find(params[:id])
    if @product.check_transaction && @product.destroy
      flash[:error] = nil
      flash[:notice] = "Successfully delete product"
    else
      flash[:notice] = nil
      flash[:error] = "Can't delete product. data in use"
    end
    get_paginated_products
    respond_to do |format|
      format.js
    end
  end

  # GET /goods/1/edit
  def edit
    @product = Product.find params[:id]
    @catalog = []
    @product.catalogs.each do |cata|
      @catalog << cata.id
    end
    load_master_data_for_goods
    @m_class = MClass.find_by_id(@product.m_class_id)
    @brand = @product.brand
    @supplier = @brand.supplier
    @brands = @supplier.brands
    @colour1 = @product.colour
    @colour2 = @product.colour2
    @colour3 = @product.colour3
    @colour4 = @product.colour4
    @unit = @product.unit
    @size = @product.size rescue ''
    @size_details = @size.sorted_size_details
    @branch_prices = BranchPrice.where("product_id=#{@product.id}")
    @total = 0
    @m_classes = MClass.where("parent_id IS NOT NULL AND level=1")
    @product_size = ProductSize.find_by_product_id(@product.id)
    @product_details = ProductDetail.joins(:product_size).where("product_sizes.product_id=#{@product.id} AND warehouse_id IN (#{current_user.current_offices.map(&:id).join(', ')})").group_by(&:product_size_id)
    @can_manage_product = current_user.can_manage_product?
  end

  def set_department_m_class m_class
    department_m_class = []
    current_m_class = m_class
    while current_m_class.present? do
      department_m_class << current_m_class.name
      current_m_class = current_m_class.m_class
    end
    return department_m_class.join(' > ')
  end

  # POST /goods
  def create
    @product = Product.find params[:product_id]

    old_size_detail = SizeDetail.find_by_size_id_and_size_number @product.size_id, params[:old_size]
    old_ps = ProductSize.find_by_product_id_and_size_detail_id params[:product_id], old_size_detail.id

    new_size_detail = SizeDetail.find_by_size_id_and_size_number @product.size_id, params[:old_size]
    new_ps = ProductSize.find_by_product_id_and_size_detail_id params[:product_id], old_size_detail.id

    old_pd = ProductDetail.find_by_product_size_id_and_warehouse_id(old_ps.id, params[:head_office_id])
    new_pd = ProductDetail.find_by_product_size_id_and_warehouse_id(old_ps.id, params[:head_office_id])
    ChangeBarcode.create old_product_size_id: old_ps.id, new_product_size_id: new_ps.id, quantity: params[:quantity], office_id: params[:head_office_id]
    respond_to do |format|
      format.html{redirect_to change_barcodes_url}
    end
  end

  # POST /goods
  def update
    @product = Product.find params[:id]
    raise @product.inspect
  end

  def copy_by_colour
    @good = Product.where(:article => params[:article], :brand_id => params[:brand_id])
    if @good.present?
      arr_state = Product::STATUS
      arr_state.each do |state|
        puts brand = Brand.find(params[:brand_id])
        puts colour = Colour.find(params[:colour_id])
        puts type_code = Type.find(params[:type_id])
        puts ar = article_code_copy.to_s.rjust(4, '0')
       
        @copy_good = @good.first.dup
        @copy_good.colour_id = params[:colour_id]
        @copy_good.status = state
        puts "-==============="
        puts @copy_good.barcode = [init_status(state), (type_code.code rescue ''), (brand.code rescue ''), ar , (colour.code rescue '')].compact.join('')
           
        @copy_good.save
      end
      @pres = true
    else
      @pres = false
    end
    render json: @good

  end

  def branch_stock
    respond_to do |format|
      format.html
    end
  end

  def setting_prices
    
  end

  def all_branches_stock
    goods = Product.find_by_barcode(params[:search])
    if goods.present?
      goods_sizes = goods.goods_sizes
      if goods_sizes.present?
        size_number = goods.size.size_details.map(&:size_number)
        @data = {"barang" => [goods.brand.name, goods.article, goods.colour.name, goods.selling_price, params[:search], goods.type.name], "data" => {},
          "jumlah" => {}, "size" => size_number}

        Office.all.each do |office|
          store = office.stores.map(&:id)
          @data["data"]["#{office.name}"] =  {"data_branch" => office.name, "stock" => {}, "each_cabang" => {}}
          goods_sizes.each do |goods_size|
            goods_details = goods_size.goods_details
            goods_store = goods_details.where(store_id: store)
            size_number = goods_size.size_detail.size_number
            @data["data"][office.name]["stock"]["#{size_number}"] = goods_store.sum(:quantity)
            @data["data"][office.name]["each_cabang"]["#{size_number}"] = goods_store.map{|x|"#{x.store.name}: #{x.quantity}"}.join('<br/>')
            @data["jumlah"]["#{size_number}"] = goods_details.sum(:quantity)
          end
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def detail_branches
    @goods = Product.where("article LIKE '%#{params[:keyword]}%' AND brand_id = #{params[:brand_id]}")
  end

  def search
    @goods = Product.search(params[:search]).first || []
    @sizes = (@goods.goods_details.group_by(&:size_detail_id).map{|goods_details|goods_details[1].first}.map{|goods_detail|
        [goods_detail.size_detail.size_number, goods_detail.quantity]
      }.sort if @goods.present?) || []

    respond_to do |format|
      format.js
    end
  end

  def new
    @change_barcode = ChangeBarcode.new
    @product = Product.find params[:product_id]
  end

  def search_purchase_price_after_discount
    brand = Brand.find_by_name(params[:brand])
    purchase_price = params[:cost_of_goods]
    discount_rp = brand.discount_rp rescue 0
    discount_percent1 = brand.discount_percent1 rescue 0
    discount_percent2 = brand.discount_percent2 rescue 0
    discount_percent3 = brand.discount_percent3 rescue 0
    price_after_discount_1 = purchase_price.to_f - discount_rp.to_f
    price_after_discount_2 = price_after_discount_1.to_f*(100-discount_percent1.to_f)/100
    price_after_discount_3 = price_after_discount_2.to_f*(100-discount_percent2.to_f)/100
    end_of_price_after_discount = price_after_discount_3.to_f*(100-discount_percent3.to_f)/100

    purchase_price_after_discount = end_of_price_after_discount

    if purchase_price_after_discount <= 0
      purchase_price_after_discount = 0
    end

    respond_to do |format|
      format.json {render json: {purchase_price_after_discount: purchase_price_after_discount, d1: discount_percent1, d2: discount_percent2, d3: discount_percent3, discount_rp: discount_rp}}
    end
  end

  def get_purchase_price_after_discount_by_brand_id
    brand = Brand.find_by_id(params[:brand_id])
    purchase_price = params[:cost_of_goods]
    discount_rp = brand.discount_rp rescue 0
    discount_percent1 = brand.discount_percent1 rescue 0
    discount_percent2 = brand.discount_percent2 rescue 0
    discount_percent3 = brand.discount_percent3 rescue 0
    price_after_discount_1 = purchase_price.to_f - discount_rp.to_f
    price_after_discount_2 = price_after_discount_1.to_f*(100-discount_percent1.to_f)/100
    price_after_discount_3 = price_after_discount_2.to_f*(100-discount_percent2.to_f)/100
    end_of_price_after_discount = price_after_discount_3.to_f*(100-discount_percent3.to_f)/100

    purchase_price_after_discount = end_of_price_after_discount

    if purchase_price_after_discount <= 0
      purchase_price_after_discount = 0
    end

    render json: {purchase_price_after_discount: purchase_price_after_discount, d1: discount_percent1, d2: discount_percent2, d3: discount_percent3, discount_rp: discount_rp}
  end

  def autocomplete_goods_barcode
    hash = []
    conditions = ["barcode LIKE '%#{params[:term]}%'"]
    conditions.push("suppliers.code='#{params[:supplier_code]}'") if params[:supplier_code].present?
    conditions << "barcode NOT IN (#{params[:present_product]})" if params[:present_product].present?
    goods = Product.joins(brand: :supplier).where(conditions.join(' AND ')).limit(25)
    goods.collect do |g|
      hash << {
        "id" => g.id, "name" => g.barcode, "value" => g.barcode, department_id: g.brand.department.id, department_name: g.brand.department.name, m_class_id: g.m_class_id, m_class_name: g.m_class.name,
        brand_id: g.brand_id, brand_name: g.brand.name, article: g.article
      }
    end

    respond_to do |format|
      format.json {render json: hash}
    end
  end

  def search_by_data
    goods = Product.cari_data(params)
    if goods.present?
      goods_sizes = goods.goods_sizes
      if goods_sizes.present?
        size_number = goods.size.size_details.map(&:size_number)
        @data = {"barang" => [goods.brand.name, goods.article, goods.colour.name, goods.selling_price, goods.barcode, goods.type.name], "data" => {},
          "jumlah" => {}, "size" => size_number}

        Office.all.each do |office|
          store = office.stores.map(&:id)
          @data["data"]["#{office.name}"] =  {"data_branch" => office.name, "stock" => {}, "each_cabang" => {}}
          goods_sizes.each do |goods_size|
            goods_details = goods_size.goods_details
            goods_store = goods_details.where(store_id: store)
            size_number = goods_size.size_detail.size_number
            @data["data"][office.name]["stock"]["#{size_number}"] = goods_store.sum(:quantity)
            @data["data"][office.name]["each_cabang"]["#{size_number}"] = goods_store.map{|x|"#{x.store.name}: #{x.quantity}"}.join('<br/>')
            @data["jumlah"]["#{size_number}"] = goods_details.sum(:quantity)
          end
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def print_barcode
    render layout: false
  end

  def search_article
    goods = Product.find_by_article(params[:article]) rescue nil
    respond_to do |format|
      format.json {render json: goods}
    end
  end

  def search_filter_by_name
    @types = Type.where(:parent_id => params[:id])
    respond_to do |format|
      format.js
    end
  end

  def search_filter_by_sub_type
    @goods = Product.where(:type_id => params[:id], :status => "Putus").paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      format.js
    end
  end

  def search_filter_by_brands
    @goods = Product.where(:brand_id => params[:id], :status => "Putus").paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      format.js
    end
  end

  def search_filter_by_brands_po
    @goods = Product.where(:brand_id => params[:id], :status => "Putus").paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      format.js
    end
  end

  def search_filter_by_article_po
    @goods = Product.where(:article => params[:id], :status => "Putus").paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      format.js
    end
  end

  def search_filter_by_merk_distribusi
    @receipt_id = params[:receipt_id]
    @goods = Product.joins(:product_receipt_details).where("brand_id = '#{params[:id]}' AND  goods_receipt_details.goods_receipt_id  = '#{params[:receipt_id]}'").group("barcode").paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      format.js
    end
  end

  def search_filter_by_article_distribusi
    @receipt_id = params[:receipt_id]
    @goods = Product.joins(:product_receipt_details).where("article = '#{params[:id]}' AND  goods_receipt_details.goods_receipt_id  = '#{params[:receipt_id]}'").group("barcode").paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      format.js
    end
  end

  def search_filter_by_article
    @article = params[:id]
    @brand_id = params[:brand_id]
    if @brand_id.present? 
      @goods = Product.where(:article => @article, :brand_id => @brand_id, :status => "Putus").paginate(:page => params[:page], :per_page => 10) || []
      @goods_colour = Product.where(:article => params[:id], :brand_id => @brand_id, :status => "Putus").group(:colour_id)
      @goods_another_colour = Colour.all
      @type_id = @goods.first.type_id
    else
      @goods_colour = Product.where(:article => params[:id], :status => "Putus").group(:colour_id)
      @goods = Product.where(:article => @article, :status => "Putus").paginate(:page => params[:page], :per_page => 10) || []
      @goods_another_colour = Colour.all
      @type_id = @goods.first.type_id
    end
    @goods_colours = Colour.all

    respond_to do |format|
      format.js
    end
  end

  def detail_good_by_brand
    if params[:id].present?
      goods = Product.find(params[:id])
      @results = {error:1}
      return render json: result if goods.nil?
      
    else
      @results = {error:1}
      return render json: result
      #      conditions = []
      #      conditions << "brands.name='#{params[:brand]}'" if params[:brand].present?
      #      conditions << "colours.name='#{params[:colour]}'" if params[:colour].present?
      #      conditions << "article='#{params[:article]}'" if params[:article].present?
      #      goods = Product.joins(:brand, :colour).last(conditions: [conditions.join(' AND ')])
    end
    @results = goods.get_pmb_goods_detail
    # @results = @result.to_h
    
    render json: @results
  end

  def detail_good_by_article
    if params[:id].present?
      goods = Product.find(params[:id])
      @result = {error:1}
      return render json: result if goods.nil?
      
    else
      @result = {error:1}
      return render json: result
      #      conditions = []
      #      conditions << "brands.name='#{params[:brand]}'" if params[:brand].present?
      #      conditions << "colours.name='#{params[:colour]}'" if params[:colour].present?
      #      conditions << "article='#{params[:article]}'" if params[:article].present?
      #      goods = Product.joins(:brand, :colour).last(conditions: [conditions.join(' AND ')])
    end
    @result = goods.get_pmb_goods_detail

    render json: @results
  end

  def detail_colour_article
    @goods = Product.joins(:colour).where(:article => params[:article], :status => "Putus").group("colour_id").select("colour_id, colours.name, status, barcode")
    render json: @goods.to_json
  end

  def search_filter_by_colour
    if params[:id].blank?
      @goods = Product.where(:status => "Putus").paginate(:page => params[:page], :per_page => 10) || []
    elsif params[:article].present? && params[:id].blank?
      @goods = Product.where(:article => params[:article], :status => "Putus").paginate(:page => params[:page], :per_page => 10) || []
      @barcode = @goods.first.barcode unless @goods.first.nil?
    elsif params[:article].present? && params[:id].present?
      @goods = Product.where(:article => params[:article], :colour_id => params[:id], :status => "Putus").paginate(:page => params[:page], :per_page => 10) || []
      @barcode = @goods.first.barcode unless @goods.first.nil?
      find_size_goods(@barcode)
    else
      @goods = Product.where(:colour_id => params[:id], :status => "Putus").paginate(:page => params[:page], :per_page => 10) || []
    end
    respond_to do |format|
      format.js
    end
  end

  def get_receipt_data
    @pmb = ProductReceipt.find(params[:receipt_id])
    @goods = Product.find_by_barcode(params[:barcode]) 
    # @goods = @pmb.goods_receipt_details.find_by_goods_id(@good.id)
    # ap @goods
    @detail = @goods.get_pmb_goods_in_distribution

    @goods_details = @pmb.get_pmb_goods_receipt_detail
    @pmb_id = params[:receipt_id]
    respond_to do |format|
      format.js
    end
  end

  def stock
   # return not_authorized unless current_user.can_view_stock_all_branches?
#    current_user = User.find_by_id(params[:user_id]) if current_user.blank?
    conditions = ["products.id IN (SELECT product_id FROM product_sizes WHERE id IN (SELECT product_size_id FROM product_details WHERE available_qty>0 AND warehouse_id IN (#{(params[:search][:branch].keys.join(',') rescue 0)})))"]
    @current_offices = current_user.offices
    if params[:search].present?
      @brand = Brand.find_by_name params[:search]["brands.name"]
      params[:search].each{|param|
        if param[0] == "status3" or param[0] == "status4"
          params[:search][param[0]].each{|status|
            conditions << "LOWER(#{param[0]}) = LOWER('#{status[1]}')"
          }
        else
          params[:search].each{|param|
            conditions << "LOWER(#{param[0]}) = LOWER('#{param[1]}')" if param[1].present? && param[0] != 'branch'
          }
        end
      }
      @supplier = @brand.supplier if @brand.present?
      @products = Product.joins(:brand).where(conditions.join(' AND ')).group_by{|product|product.brand.department_id}
      @departments = MClass.where(id: @products.keys.join(','))
      @offices = Office.where(id: params[:search][:branch].keys)
    else
      @offices = current_user.offices
    end
  end

  def mclass_per_department
    @cat_num = params[:cat_num].to_i rescue 0
    @cat = MClass.where("parent_id=#{params[:cat_id]}").select("id, (code || '-' || name) AS name").order("code ASC")
    if @cat.blank?
      @cat_num = 5
    end
  end

  private
  def get_paginated_products
    departments = Department.where("id IN (SELECT department_id FROM office_departments WHERE office_id IN (#{current_user.offices.map(&:id).push(0).join(' , ')}))") rescue [0]
    conditions = ["brands.department_id IN (#{departments.map(&:id).push(0).join(', ')})"]
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @products = Product.joins(:m_class, :colour, :size, brand: :supplier).joins("LEFT JOIN m_classes departments ON departments.id=products.department_id")
      .select("colour_code, brands.name AS brand_name, suppliers.name AS supplier_name, colours.name AS colour_name, m_classes.name AS m_class_name, products.*, sizes.description AS size_name, selling_price, purchase_price,
        departments.name AS department_name")
      .where(conditions.join(' AND ')).order(default_order('products')).paginate(page: params[:page], per_page: 10) || []
#    flash[:warning] = "No Department in HO or branch. Please set the department before you can see the product" if @products.blank?
  end

  def load_master_data_for_goods
    @brands = Brand.limit(7).order('name')
    @suppliers = Supplier.limit(7).order('name')
    @colours = Colour.limit(7).order('name').map(&:name)
    @units = Unit.limit(7).order('name').map(&:name)
    @departments = MClass.where("parent_id IS NULL").limit(7).order('name').map(&:name)
    @m_classes = [[], [], [], [], []]
    @sizes = Size.limit(7).order("concat(code, ' / ', description)").select("concat(code, ' / ', description) AS name, id")
    @size = @product.size rescue ''
    @now = Time.now.strftime('%Y-%m-%d')
    @size_details = @size.size_details rescue []
  end

  def article_code_copy
    #generate code
    find_data_article = Product.where("type_id = ? and brand_id = ? and article = ? and code is not null", @good.first.type_id, @good.first.brand_id, @good.first.article).first
    return find_data_article.code if find_data_article.present?

    max_code_article = Product.where("type_id = ? and brand_id = ? and code is not null", @good.first.type_id, @good.first.brand_id).group(:code).maximum(:code).values.first
    (max_code_article.to_i rescue 0) + 1
  end

  def article_code
    #generate code
    find_data_article = Product.where("type_id = ? and brand_id = ? and article = ? and code is not null", params[:product][:type_id], params[:product][:brand_id], params[:product][:article]).first
    return find_data_article.code if find_data_article.present?

    max_code_article = Product.where("type_id = ? and brand_id = ? and code is not null", params[:product][:type_id], params[:product][:brand_id]).group(:code).maximum(:code).values.first
    (max_code_article.to_i rescue 0) + 1
  end

  def product_params
    params.require(:product).permit(
      :article, :purchase_price, :purchase_price_date, :cost_of_products, :cost_date, :selling_price, :sell_price_date, :netto, :image, :status1, :status2, :status3, :first_po,
      :margin_percent1, :margin_percent2, :margin_percent3, :margin_percent4, :margin_rp, :colour_code, :discount_percent, :harga_kredit, :harga_member_eceran, :harga_eceran,
      :harga_bandrol, :margin_percent, :status5, product_sizes_attributes: [:size_detail_id, :default_min_stock, product_details_attributes: [[:min_stock, :available_qty, :allocated_qty, :freezed_qty,
      :rejected_qty, :online_qty, :defect_qty]]], branch_prices_attributes: [:branch_id, :percentage, :nominal, :additional_min_stock]
    )
  end

  def can_view_product
    not_authorized unless current_user.can_view_product?
  end

  def can_manage_product
    not_authorized unless current_user.can_manage_product?
  end
end
