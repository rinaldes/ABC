class SuppliersController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :can_view_supplier, only: [:index, :show]
  before_filter :can_manage_supplier, only: [:new, :create, :edit, :update]

  autocomplete :supplier, :name

  def import
    import_result = Supplier.import(params[:file])
    if %w(text/csv application/vnd.ms-excel).include?params[:file].content_type
      if import_result[:error] == 1
        flash[:error] = import_result[:message]
      else
        flash[:notice] = import_result[:message]
      end
    else
      flash[:error] = "Please attach CSV File"
    end
    redirect_to suppliers_path
  end

  def add_contact
    respond_to do |format|
      format.js
    end
  end

  def add_bank_account
    respond_to do |format|
      format.js
    end
  end

  def index
    get_paginated_suppliers
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.xls
      if(params[:a] == "a")
        format.csv { send_data Supplier.all.to_csv2 }
      else
        format.csv { send_data Supplier.all.to_csv }
      end
    end
  end

  def new
    @supplier = Supplier.new(params[:supplier])
    load_departments
    respond_to do |format|
      format.html
    end
  end

  # GET /users/1
  def show
    @supplier = Supplier.find(params[:id])
    @depart = @supplier.departments
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def get_number
    @supplier_number = Supplier.number(params)
    respond_to do |format|
      format.js
    end
  end

  # GET /suppliers/1/edit
  def edit
    @supplier = Supplier.find(params[:id])
    load_departments
    respond_to do |format|
      format.html
    end
  end

  # POST /suppliers
  # POST /suppliers.json
  def create
    @supplier = Supplier.new(supplier_params.merge(code: ("S#{('%04d' % ((Supplier.last.code.last.to_i rescue 0)+1))}")))
    if @supplier.save
      flash[:notice] = 'Supplier berhasil ditambahkan'
      redirect_to suppliers_path
    else
      load_departments
      flash[:error] = @supplier.errors.full_messages.join('<br/>')
      render "new"
    end
  end

  # PUT /suppliers/1
  # PUT /suppliers/1.json
  def update
    @supplier = Supplier.find(params[:id])
    old_contacts = @supplier.contact_people.map(&:id)
    old_accounts = @supplier.bank_accounts.map(&:id)
    old_departments = @supplier.supplier_departments.map(&:id)
    if @supplier.update_attributes(supplier_params)
      ContactPerson.where(id: old_contacts).delete_all
      BankAccount.where(id: old_accounts).delete_all
      SupplierDepartment.where(id: old_departments).delete_all
      flash[:notice] = 'Supplier was successfully updated.'
      redirect_to suppliers_path
    else
      load_departments
      flash[:error] = @supplier.errors.full_messages.join('<br/>')
      render "edit"
    end
  end

  def destroy
    @supplier = Supplier.find(params[:id])
    if @supplier.check_transaction && @supplier.destroy
      flash[:error] = nil
      flash[:notice] = "Successfully delete supplier"
    else
      flash[:notice] = nil
      flash[:error] = "Can't delete supplier. data in use"
    end
    get_paginated_suppliers
    respond_to do |format|
      format.js
    end
  end

  def search
    @suppliers = Supplier.search(params[:search]).uniq.paginate(:page => params[:page], :per_page => 100) || []
    respond_to do |format|
      @supplier = Supplier.new
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

  def autocomplete_supplier_name
    hash = []
    suppliers = Supplier.where("LOWER(name) LIKE LOWER('%#{params[:term]}%')").limit(25)
    suppliers.collect do |p|
      hash << {"id" => p.id, "label" => p.name, "value" => p.name, "code" => p.code, "address" => p.address}
    end
    render json: hash
  end

  def autocomplete_supplier_code
    hash = []
    suppliers = Supplier.where("LOWER(code) LIKE LOWER('%#{params[:term]}%')").limit(25)
    suppliers.collect do |p|
      hash << {"id" => p.id, "label" => "#{p.code} - #{p.name}", "name" => p.name, "value" => p.code, "address" => p.address, 'id' => p.id}
    end
    render json: hash
  end

  private
  def get_paginated_suppliers
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @suppliers = Supplier.where(conditions.join(' AND ')).order(default_order).paginate(page: params[:page], per_page: 10) || []
  end

  def supplier_params
    params.require(:supplier).permit(
      :address, :city, :code, :email, :fax, :hp1, :hp2, :name, :person, :phone, :send_address, :send_city, :pinbb, :no_bill, :bank, :branch, :long_term, :suptype,
      :setup_discount, :contact_name, contact_people_attributes: [:name, :phone, :pinbb, :email], bank_accounts_attributes: [:name, :account_number, :bank_name, :branch, :city],
      supplier_departments_attributes: [:department_id]
    )
  end

  def can_view_supplier
    not_authorized unless current_user.can_view_supplier?
  end

  def can_manage_supplier
    not_authorized unless current_user.can_manage_supplier?
  end
end
