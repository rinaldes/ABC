class CashbacksController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  #autocomplete :cashback, :name
  before_filter :can_view_cashback, only: [:index, :show]
  before_filter :can_manage_cashback, only: [:new, :create, :edit, :update]

  def index
    get_paginated_cashbacks
    respond_to do |format|
      format.html
      format.js
      format.xls
      if(params[:a] == "a")
        format.csv { send_data Cashback.all.to_csv2 }
      else
        format.csv { send_data Cashback.all.to_csv }
      end
    end
  end

  def import
    import_result = Cashback.import(params[:file])
    if params[:file].present?
      if import_result[:error] == 1
        flash[:error] = import_result[:message]
      else
        flash[:notice] = import_result[:message]
      end
    else
      flash[:error] = "Please attach CSV File"
    end
    redirect_to cashbacks_path
  end

  def show
    @cashback = Cashback.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def new
    @cashback = Cashback.new(params[:cashback])
    respond_to do |format|
      format.html
    end
  end

  def edit
    @cashback = Cashback.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def create
    @cashback = Cashback.new(cashback_params)
    if @cashback.save
      flash[:notice] = 'Cashback berhasil ditambahkan'
      redirect_to cashbacks_path
    else
      flash[:error] = @cashback.errors.full_messages.join('<br/>')
      render "new"
    end
  end

  def update
    @cashback = Cashback.find(params[:id])
    if @cashback.update_attributes(cashback_params)
      flash[:notice] = 'Cashback berhasil ditambahkan'
      redirect_to cashbacks_path
    else
      flash[:error] = @cashback.errors.full_messages.join('<br/>')
      render "edit"
    end
  end

  def destroy
    @cashback = Cashback.find(params[:id])
    if @cashback.check_transaction && @cashback.destroy
      flash[:error] = nil
      flash[:notice] = "Successfully delete cashback"
    else
      flash[:notice] = nil
      flash[:error] = "Can't delete cashback. data in used"
    end
    get_paginated_cashbacks
    respond_to do |format|
      format.js
    end
  end

  def search
    @cashbacks = Cashback.search(params[:search]).uniq.paginate(:page => params[:page], :per_page => 10) || []
    respond_to do |format|
      @cashback = Cashback.new
      format.js
    end
  end

  def get_number
    @cashback_number = Cashback.number(params)
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
  def cashback_params
    params.require(:cashback).permit(:cashback_amount, :transaction_amount, :member_level_id)
  end

  def can_view_cashback
    not_authorized unless current_user.can_view_promo?
  end

  def can_manage_cashback
    not_authorized unless current_user.can_manage_promo?
  end
end
