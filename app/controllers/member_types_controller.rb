class MemberTypesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  autocomplete :member_type, :name
  before_filter :can_view_member_type, only: [:index, :show]
  before_filter :can_manage_member_type, only: [:new, :create, :edit, :update]

  def index
    get_paginated_member_types
    respond_to do |format|
      format.html
      format.js
      format.xls
      if(params[:a] == "a")
        format.csv { send_data MemberType.all.to_csv2 }
      else
        format.csv { send_data MemberType.all.to_csv }
      end
    end
  end

  def import
    import_result = MemberType.import(params[:file])
    if params[:file].present?
      if import_result[:error] == 1
        flash[:error] = import_result[:message]
      else
        flash[:notice] = import_result[:message]
      end
    else
      flash[:error] = "Please attach CSV File"
    end
    redirect_to member_types_path
  end

  def new
    @member_type = MemberType.new(params[:member_type])
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @member_type = MemberType.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def create
    init = params[:member_type][:name][0]
    member_type_number = MemberType.create_number(params)
    @member_type = MemberType.new(member_type_params.merge(code: ("C#{('%03d' % ((MemberType.last.code.gsub('C', '').to_i rescue 0)+1))}")))
    if @member_type.save
      flash[:notice] = 'Member Type berhasil ditambahkan'
      redirect_to member_types_path
    else
      flash[:error] = @member_type.errors.full_messages.join('<br/>')
      render "new"
    end
  end

  def update
    @member_type = MemberType.find(params[:id])
    if @member_type.update_attributes(member_type_params)
      flash[:notice] = 'Member Type berhasil ditambahkan'
      redirect_to member_types_path
    else
      flash[:error] = @member_type.errors.full_messages.join('<br/>')
      # format.js
      render "edit"
    end
  end

  def destroy
    @member_type = MemberType.find(params[:id])
    if @member_type.destroy
      flash[:error] = nil
      flash[:notice] = "Successfully delete member_type"
    else
      flash[:notice] = nil
      flash[:error] = "Can't delete member_type. data in used"
    end
    get_paginated_member_types
    respond_to do |format|
      format.js
    end
  end

  def search
    @member_types = MemberType.search(params[:search]).uniq.paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      @member_type = MemberType.new
      format.js
    end
  end

  def get_number
    @member_type_number = MemberType.number(params)
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
  def member_type_params
    params.require(:member_type).permit(:code, :name)
  end

  def can_view_member_type
    not_authorized unless current_user.can_view_member?
  end

  def can_manage_member_type
    not_authorized unless current_user.can_manage_member?
  end
end
