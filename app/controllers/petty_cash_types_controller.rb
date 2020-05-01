class PettyCashTypesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  autocomplete :petty_cash_type, :name
  before_filter :can_view_petty_cash_type, only: [:index, :show]
  before_filter :can_manage_petty_cash_type, only: [:new, :create, :edit, :update]

  def index
    get_paginated_petty_cash_types
    respond_to do |format|
      format.html
      format.js
      format.xls
      if(params[:a] == "a")
        format.csv { send_data PettyCashType.all.to_csv2 }
      else
        format.csv { send_data PettyCashType.all.to_csv }
      end
    end
  end

  def import
    import_result = PettyCashType.import(params[:file])
    if params[:file].present?
      if import_result[:error] == 1
        flash[:error] = import_result[:message]
      else
        flash[:notice] = import_result[:message]
      end
    else
      flash[:error] = "Please attach CSV File"
    end
    redirect_to petty_cash_types_path
  end

  def new
    @petty_cash_type = PettyCashType.new(params[:petty_cash_type])
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @petty_cash_type = PettyCashType.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def create
    init = params[:petty_cash_type][:name][0]
    petty_cash_type_number = PettyCashType.create_number(params)
    @petty_cash_type = PettyCashType.new(petty_cash_type_params.merge(code: ("PCT#{('%03d' % ((PettyCashType.last.code.gsub('PCT', '').to_i rescue 0)+1))}")))
    if @petty_cash_type.save
      flash[:notice] = 'Petty Cash Type berhasil ditambahkan'
      redirect_to petty_cash_types_path
    else
      flash[:error] = @petty_cash_type.errors.full_messages.join('<br/>')
      render "new"
    end
  end

  def update
    @petty_cash_type = PettyCashType.find(params[:id])
    if @petty_cash_type.update_attributes(petty_cash_type_params)
      flash[:notice] = 'Petty Cash Type berhasil ditambahkan'
      redirect_to petty_cash_types_path
    else
      flash[:error] = @petty_cash_type.errors.full_messages.join('<br/>')
      # format.js
      render "edit"
    end
  end

  def destroy
    @petty_cash_type = PettyCashType.find(params[:id])
    if @petty_cash_type.destroy
      flash[:error] = nil
      flash[:notice] = "Successfully delete petty_cash_type"
    else
      flash[:notice] = nil
      flash[:error] = "Can't delete petty_cash_type. data in used"
    end
    get_paginated_petty_cash_types
    respond_to do |format|
      format.js
    end
  end

  def search
    @petty_cash_types = PettyCashType.search(params[:search]).uniq.paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      @petty_cash_type = PettyCashType.new
      format.js
    end
  end

  def get_number
    @petty_cash_type_number = PettyCashType.number(params)
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
  def petty_cash_type_params
    params.require(:petty_cash_type).permit(:code, :name)
  end

  def can_view_petty_cash_type
    not_authorized unless current_user.can_view_petty_cash?
  end

  def can_manage_petty_cash_type
    not_authorized unless current_user.can_manage_petty_cash?
  end
end
