class BrandsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  autocomplete :brand, :name
  skip_before_filter :authenticate_user!, only: :autocomplete_brand_name
  before_filter :can_view_brand, only: [:index, :show]
  before_filter :can_manage_brand, only: [:new, :create, :edit, :update]

  # GET /brands
  # GET /brands.json
  def index
    get_paginated_brands
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.xls
      if(params[:a] == "a")
        format.csv { send_data Brand.all.to_csv2 }
      else
        format.csv { send_data Brand.all.to_csv }
      end
    end
  end

  def generate_data_brand
    @brand = Brand.find params[:brand_id]
    respond_to do |format|
      format.js
    end
  end

  def brands_per_supplier
    @brands = Brand.where("supplier_id=#{params[:supplier_id]}").limit(11)
    respond_to do |format|
      format.js
    end
  end

  def import
    import_result = Brand.import(params[:file])
    if %w(text/csv application/vnd.ms-excel).include?params[:file].content_type
      if import_result[:error] == 1
        flash[:error] = import_result[:message]
      else
        flash[:notice] = import_result[:message]
      end
    else
      flash[:error] = "Please attach CSV File"
    end
    redirect_to brands_path
  end

  def new
    @brand = Brand.new set_harga: 'Manual'
    load_master
    respond_to do |format|
      format.html
    end
  end

  def search_supplier
    Supplier.where("name like ?", "%#{params[]}%")
  end

  # GET /brands/1/edit
  def edit
    @brand = Brand.find_by_id(params[:id])
    @supplier = @brand.supplier
    @departments = @supplier.departments
    load_master
    respond_to do |format|
      format.html
    end
  end

  def load_master
    #@departments = MClass.where("parent_id IS NULL").select("name, id").order("name").map{|department|[department.name, department.id]}
    @departments = Department.where("parent_id is null");
    @suppliers = Supplier.select("name, id").limit(11).order("name").map{|supplier|[supplier.name, supplier.id]}
  end

  # POST /brands
  # POST /brands.json
  def create
    @brand = Brand.new(brand_params.merge(supplier_id: (Supplier.find_by_name(params[:supplier_id]).id rescue nil), code: "B#{(('%03d' % ((Brand.last.code.gsub('B', '').to_i rescue 0)+1)))}", discount_rp: params[:discount_rp2]))
    if @brand.save
      flash[:notice] = 'Merk berhasil ditambahkan.'
      redirect_to brands_path
    else
      load_master
      flash[:error] = @brand.errors.full_messages.join('<br/>')
      render "new"
    end
  end

  # PUT /brands/1
  # PUT /brands/1.json
  def update
    @brand = Brand.find_by_id(params[:id])
    respond_to do |format|
      if @brand.update_attributes(brand_params.merge(supplier_id: (Supplier.find_by_name(params[:supplier_id]).id)))
        flash[:notice] = 'Brand was successfully updated.'
        format.html{redirect_to brands_path}
      else
        load_master
        flash[:error] = @brand.errors.full_messages
        format.html{render "edit"}
      end
    end
  end

  # DELETE /brands/1
  # DELETE /brands/1.json
  def destroy
    @brand = Brand.find(params[:id])
    if @brand.destroy
      flash.now[:notice] = 'Merk berhasil dihapus.'
    else
      flash.now[:error] = 'Merk tidak dapat dihapus karena sudah ada dipakai.'
    end
    get_paginated_brands
    respond_to do |format|
      format.js
    end
  end

  def search
    @brands = Brand.search(params[:search]).paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      @brand = Brand.new
      format.js
    end
  end

  def show
    @brand = Brand.find(params[:id])
  end

  def autocomplete_brand_name
    hash = []
    conditions = ["LOWER(brands.name) like LOWER('%#{params[:term]}%')"]
    conditions << "suppliers.name='#{params[:supplier_name]}'" if params[:supplier_name].present?
    supplier = Brand.where(conditions.join(' AND ')).limit(11).order('brands.name').joins(:supplier)
    supplier.collect do |p|
      hash << {"id" => p.id, "label" => p.name, "value" => p.name, supplier_name: p.supplier.name, department_name: (p.department.name rescue ''),
      discount_percent1: p.discount_percent1, discount_percent2: p.discount_percent2, discount_percent3: p.discount_percent3, discount_percent4: p.discount_percent4}
    end
    render json: hash
  end

  private
  def brand_params
    params.require(:brand).permit(:code, :set_harga, :name, :discount_percent1, :discount_percent2, :discount_percent3, :discount_percent4, :department_id)
  end

  def can_view_brand
    not_authorized unless current_user.can_view_brand?
  end

  def can_manage_brand
    not_authorized unless current_user.can_manage_brand?
  end
end
