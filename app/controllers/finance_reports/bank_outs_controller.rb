class FinanceReports::BankOutsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :prepare_bank_outs, only: [:index]
  before_filter :can_manage_bank_out_report, only: [:index, :show]
  before_filter :get_bank_out, only: [:show, :export]

  add_crumb "Finance", '/'
  add_crumb("Bank Out".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_bank_outs_path }
  add_crumb("List".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_bank_outs_path }

  def index
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def export
    filename = "Bank Out Report.xlsx"
    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end

  private
    def get_bank_out
      @bank_out = AccountPayable.find_by_id(params[:id])
      @debit = AccountPayable.get_debit_value(@bank_out)
    end

    def prepare_bank_outs
      @suppliers = Supplier.all
      @ap_numbers = AccountPayable.pluck(:ap_number)
      results = AccountPayable.get_report_bank_outs(params[:supplier_id], params[:ap_number]).order('created_at DESC')
      @bank_outs = results.page(params[:page]).per(PER_PAGE)
    end

    def can_manage_bank_out_report
      not_authorized unless current_user.can_manage_bank_out_report?
    end
end
