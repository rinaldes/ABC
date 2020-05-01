class CatalogsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  autocomplete :catalog, :name
  before_filter :can_view_catalog, only: [:index, :show]
  before_filter :can_manage_catalog, only: [:new, :create, :edit, :update]

  def index
    get_paginated_catalogs
    respond_to do |format|
      format.html
      format.js
      format.xls
      if(params[:a] == "a")
        format.csv { send_data Catalog.all.to_csv2 }
      else
        format.csv { send_data Catalog.all.to_csv }
      end
    end
  end

  def import
    import_result = Catalog.import(params[:file])
    if params[:file].present?
      if import_result[:error] == 1
        flash[:error] = import_result[:message]
      else
        flash[:notice] = import_result[:message]
      end
    else
      flash[:error] = "Please attach CSV File"
    end
    redirect_to catalogs_path
  end

  def new
    @catalog = Catalog.new(params[:catalog])
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @catalog = Catalog.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def create
    init = params[:catalog][:name][0]
    catalog_number = Catalog.create_number(params)
    @catalog = Catalog.new(catalog_params.merge(code: ("C#{('%03d' % ((Catalog.last.code.gsub('C', '').to_i rescue 0)+1))}")))
    if @catalog.save
      flash[:notice] = 'Catalog berhasil ditambahkan'
      redirect_to catalogs_path
    else
      flash[:error] = @catalog.errors.full_messages.join('<br/>')
      render "new"
    end
  end

  def update
    @catalog = Catalog.find(params[:id])
    if @catalog.update_attributes(catalog_params)
      flash[:notice] = 'Catalog berhasil ditambahkan'
      redirect_to catalogs_path
    else
      flash[:error] = @catalog.errors.full_messages.join('<br/>')
      # format.js
      render "edit"
    end
  end

  def destroy
    @catalog = Catalog.find(params[:id])
    if @catalog.destroy
      flash[:error] = nil
      flash[:notice] = "Successfully delete catalog"
    else
      flash[:notice] = nil
      flash[:error] = "Can't delete catalog. data in used"
    end
    get_paginated_catalogs
    respond_to do |format|
      format.js
    end
  end

  def search
    @catalogs = Catalog.search(params[:search]).uniq.paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      @catalog = Catalog.new
      format.js
    end
  end

  def get_number
    @catalog_number = Catalog.number(params)
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
  def catalog_params
    params.require(:catalog).permit(:code, :name)
  end

  def can_view_catalog
    not_authorized unless current_user.can_view_product?
  end

  def can_manage_catalog
    not_authorized unless current_user.can_manage_product?
  end
end
