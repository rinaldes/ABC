class BranchesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  autocomplete :branch, :office_name
  before_filter :can_view_branch, only: [:index, :show]
  before_filter :can_manage_branch, only: [:new, :create, :edit, :update, :destroy]

  def destroy
    @branch = Branch.find(params[:id])
    if @branch.check_transaction && @branch.destroy
      flash[:error] = nil
      flash[:notice] = "Successfully delete branch"
    else
      flash[:notice] = nil
      flash[:error] = "Can't delete branch. data in use"
    end
    get_paginated_branches
    respond_to do |format|
      format.js
      if(params[:a] == "a")
        format.csv { send_data Branch.all.to_csv2 }
      else
        format.csv { send_data Branch.all.to_csv }
      end
    end
  end

  def import
    import_result = Branch.import(params[:file], 'Branch')
    if params[:file].present?
      if import_result[:error] == 1
        flash[:error] = import_result[:message]
      else
        flash[:notice] = import_result[:message]
      end
    else
      flash[:error] = "Please attach CSV File"
    end
    redirect_to branches_path
  end

  # POST /suppliers
  # POST /suppliers.json
  def update
    @branch = Branch.find(params[:id])
    office_departments = @branch.office_departments.map(&:id).join(', ')
    respond_to do |format|
      if @branch.update_attributes(branch_params.merge(contact_person: (User.find_by_username(params[:username]).id rescue nil)))
        @branch.office_departments.where("id IN (#{office_departments})").delete_all if office_departments.present?
        flash[:notice] = t(:successfully_updated)
      else
        @head_offices = HeadOffice.all
        @users = User.all.map{|user|[user.username, user.id]}
        load_departments
        flash[:error] = @branch.errors.full_messages.join('<br/>')
      end
      format.js
    end
  end

  def edit
    @branch = Branch.find(params[:id])
    @head_offices = HeadOffice.all
    @users = User.all.map{|user|[user.username, user.id]}
    load_departments
  end

  def new
    @branch = Branch.new
    @users = User.joins(:role).limit(7).map{|user|[user.username, user.id]}
    @head_offices = HeadOffice.all
    load_departments
    respond_to do |format|
      format.html
    end
  end

  # POST /suppliers
  # POST /suppliers.json
  def create
    @branch = Branch.new(branch_params.merge(contact_person: (User.find_by_username(params[:username]).id rescue nil)))
    @head_offices = HeadOffice.all
    @users = User.joins(:role).limit(7).map{|user|[user.username, user.id]}
    respond_to do |format|
      if @branch.save
        flash[:notice] = t(:successfully_created)
      else
        @head_offices = HeadOffice.all
        @users = User.joins(:role).limit(7).map{|user|[user.username, user.id]}
        load_departments
        flash.now[:error] = @branch.errors.full_messages.join('<br/>')
      end
      format.js
    end
  end

  def index
    get_paginated_branches
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.xls {
        filename = "Cabang_#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}.xls"
        send_data(@branches.to_xls, :type => "text/xls; charset=utf-8; header=present", :filename => filename)
      }
      format.json{
        render json: @branches.map{|branch|
          sales_sum = Sale.where("store_id=#{branch.id}").map(&:total_price).compact.sum
          target_sec2015 = 10000000
          {
            office_name: branch.description, lat: branch.lat, long: branch.long, achievement: [(sales_sum/target_sec2015*100).round(2), 100].min, target_sec2015: target_sec2015,
              secsales: sales_sum
          }
        }.to_json
      }
    end
  end

  def show
    @branch = Branch.find(params[:id])
    @departments = @branch.departments
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  private
  def branch_params
    params.require(:branch).permit(
      :office_name, :description, :warehouse, :contact_person, :phone_number, :fax_number, :mobile_phone, :address, :short_address, :head_office_id, :lat, :long,
      office_departments_attributes: [:department_id]
    )
  end

  def can_view_branch
    not_authorized unless current_user.can_view_branch?
  end

  def can_manage_branch
    not_authorized unless current_user.can_manage_branch?
  end
end
