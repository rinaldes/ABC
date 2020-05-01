class HeadOfficesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :can_view_ho, only: [:index, :show]
  before_filter :can_manage_ho, only: [:new, :create, :edit, :update, :destroy]
  autocomplete :head_office, :office_name
  before_action :set_ho, only: [:show, :destroy, :edit, :update]

  def autocomplete_head_office_office_name
    hash = []
    suppliers = HeadOffice.where("LOWER(office_name) LIKE LOWER('%#{params[:term]}%')").limit(25)
    suppliers.collect do |p|
      hash << {"id" => p.id, "label" => p.office_name, "value" => p.office_name}
    end
    render json: hash
  end

  def import
    import_result = HeadOffice.import(params[:file], 'HeadOffice')
    if params[:file].present?
      if import_result[:error] == 1
        flash[:error] = import_result[:message]
      else
        flash[:notice] = import_result[:message]
      end
    else
      flash[:error] = "Please attach CSV File"
    end
    redirect_to head_offices_path
  end

  def destroy
    if @head_office.check_transaction && @head_office.destroy
      flash[:error] = nil
      flash[:notice] = "Successfully delete unit"
    else
      flash[:notice] = nil
      flash[:error] = "Can't delete unit. data in use"
    end
    get_paginated_head_offices
    respond_to do |format|
      format.js
    end
  end

  def show
    @head_office = HeadOffice.find(params[:id])
    @depart = OfficeDepartment.where(office_id: params[:id])
  end

  def index
    get_paginated_head_offices
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.xls {
        filename = "Head_Office_#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}.xls"
        send_data(@head_offices.to_xls, :type => "text/xls; charset=utf-8; header=present", :filename => filename)
      }
      if(params[:a] == "a")
        format.csv { send_data HeadOffice.all.to_csv2 }
      else
        format.csv { send_data HeadOffice.all.to_csv }
      end
    end
  end

  # POST /suppliers
  # POST /suppliers.json
  def create
    @head_office = HeadOffice.new(head_office_params.merge(contact_person: (User.find_by_username(params[:username]).id rescue nil)))
    if @head_office.save
      flash[:notice] = 'Head Office berhasil ditambahkan'
      redirect_to head_offices_path
    else
      flash[:error] = @head_office.errors.full_messages.join('<br/>')
      user_department
      render "new"
    end
  end

  def edit
    @head_office = HeadOffice.find(params[:id])
    user_department
  end

  # POST /suppliers
  # POST /suppliers.json
  def update
    @head_office = HeadOffice.find(params[:id])
    old_departments = @head_office.office_departments.map(&:id)
    if @head_office.update_attributes(head_office_params.merge(contact_person: (User.find_by_username(params[:username]).id rescue nil)))
      OfficeDepartment.where(id: old_departments).delete_all
      flash[:notice] = 'Head Office berhasil diubah'
      redirect_to head_offices_path
    else
      user_department
      flash[:error] = @head_office.errors.full_messages.join('<br/>')
      render "new"
    end
  end

  def new
    @head_office = HeadOffice.new
    user_department
    respond_to do |format|
      format.html
    end
  end

  private
  def get_paginated_head_offices
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @head_offices = HeadOffice.joins("LEFT JOIN users ON offices.contact_person=users.id").select("offices.*, users.username").where(conditions.join(' AND '))
      .order(default_order('offices')).paginate(page: params[:page], per_page: 10) || []
  end

  def head_office_params
    params.require(:head_office).permit(:office_name, :description, :warehouse, :contact_person, :phone_number, :fax_number, :mobile_phone, :address, :short_address,
      office_departments_attributes: [:department_id])
  end

  def can_view_ho
    not_authorized unless current_user.can_view_ho?
  end

  def can_manage_ho
    not_authorized unless current_user.can_manage_ho?
  end

  def user_department
    @users = User.joins(:role).map{|user|[user.username, user.id]}
    load_departments
  end

  def set_ho
    @head_office = HeadOffice.find params[:id]
  end
end
