class EdcBankAccountsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :can_view_edc_bank_account, only: [:index, :show]
  before_filter :can_manage_edc_bank_account, only: [:new, :create, :edit, :update]

  def index
    get_paginated_edc_bank_accounts
    respond_to do |format|
      format.html
      format.js
      format.xls
      if(params[:a] == "a")
        format.csv { send_data EdcBankAccount.all.to_csv2 }
      else
        format.csv { send_data EdcBankAccount.all.to_csv }
      end
    end
  end

  def sync_edc_bank_account
    DatabaseServer.sync_edc_bank_account
  end

  def import
    import_result = EdcBankAccount.import(params[:file])
    if params[:file].present?
      if import_result[:error] == 1
        flash[:error] = import_result[:message]
      else
        flash[:notice] = import_result[:message]
      end
    else
      flash[:error] = "Please attach CSV File"
    end
    redirect_to edc_bank_accounts_path
  end

  def show
    @edc_bank_account = EdcBankAccount.find(params[:id])
    #@sales = SalesDetail.where(sale_id: @edc_bank_account.sales_id).select("article, products.description, SUM(sales_details.total_price) AS total_price, SUM(ppn) AS ppn, SUM(capital_price*quantity) AS capital_price,
    #    SUM(quantity) AS quantity").joins(:product, :sale).group("article, products.description").order("total_price DESC")
    #byebug
    respond_to do |format|
      format.html
    end
  end

  def new
    @edc_bank_account = EdcBankAccount.new(params[:edc_bank_account])
    respond_to do |format|
      format.html
    end
  end

  def edit
    @edc_bank_account = EdcBankAccount.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def create
    @edc_bank_account = EdcBankAccount.new(edc_bank_account_params)
    if @edc_bank_account.save
      flash[:notice] = 'Edc Bank Account berhasil ditambahkan'
      redirect_to edc_bank_accounts_path
    else
      flash[:error] = @edc_bank_account.errors.full_messages.join('<br/>')
      render "new"
    end
  end

  def update
    @edc_bank_account = EdcBankAccount.find(params[:id])
    if @edc_bank_account.update_attributes(edc_bank_account_params)
      flash[:notice] = 'Edc Bank Account berhasil ditambahkan'
      redirect_to edc_bank_accounts_path
    else
      flash[:error] = @edc_bank_account.errors.full_messages.join('<br/>')
      render "edit"
    end
  end

  def destroy
    @edc_bank_account = EdcBankAccount.find(params[:id])
    if @edc_bank_account.check_transaction && @edc_bank_account.destroy
      flash[:error] = nil
      flash[:notice] = "Successfully delete edc_bank_account"
    else
      flash[:notice] = nil
      flash[:error] = "Can't delete edc_bank_account. data in used"
    end
    get_paginated_edc_bank_accounts
    respond_to do |format|
      format.js
    end
  end

  def search
    @edc_bank_accounts = EdcBankAccount.search(params[:search]).uniq.paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      @edc_bank_account = EdcBankAccount.new
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

  def get_paginated_edc_bank_accounts
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @edc_bank_accounts = EdcBankAccount.where(conditions.join(' AND ')).select("edc_bank_accounts.*").order(default_order('edc_bank_accounts')).paginate(:page => params[:page], :per_page => 10) || []
  end

private
  def edc_bank_account_params
    params.require(:edc_bank_account).permit(:sales_id, :tipe, :bank_name, :account_number, :card_number, :payment_amt, :outstanding_amount, :account_name, :extra_charge)
  end

  def can_view_edc_bank_account
    not_authorized unless current_user.can_view_bank?
  end

  def can_manage_edc_bank_account
    not_authorized unless current_user.can_manage_bank?
  end
end