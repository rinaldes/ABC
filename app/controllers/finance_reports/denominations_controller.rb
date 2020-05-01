class FinanceReports::DenominationsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :can_manage_denomination_report, only: [:index]
  before_filter :get_denomination_parents, only: [:index]
  before_filter :prepare_denominations, only: [:index, :export]

  add_crumb "Finance", '/'
  add_crumb("Denomination Report".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_denominations_path }
  add_crumb("List".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_denominations_path }

  def index
    respond_to do |format|
      format.js
      format.html
    end
  end

  def export
    @branch = Branch.find_by_id(params[:branch_id])
    @date = params[:date].blank? ? Time.now.to_date.strftime("%d %b %Y") : (params[:date]["year"] + "-" + params[:date]["month"] + "-" + params[:date]["day"]).to_date.strftime("%d %b %Y")
    filename = "Denomination Report.xlsx"
    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end

  private
    def get_denomination_parents
      @branch_id = params[:branch_id].blank? ? current_user.branch_id : params[:branch_id]
      @branchs = Branch.all
      @time = Time.now
    end

    def prepare_denominations
      @sales = Sale.by_day_and_branch(params[:date], @branch_id)
      @list_income = Sale.get_variable_income(@sales)
      @list_net_sales = Sale.get_variable_net_sales(@list_income)
      @cash_outs = CashOut.get_outcome(params[:date], @branch_id)
      @list_outcome = CashOut.get_variable_outcome(@cash_outs)
      @sod_eods = SodEod.get_deposit(params[:date], @branch_id)
      @list_deposit = SodEod.get_variable_deposit(@sod_eods)
      @saldo_cash = @list_income["income_cash"] - @list_outcome["outcome_cash"] - @list_outcome["saldo_btp_income"]
      @selisih = @list_deposit["total_deposit"] - @saldo_cash
    end

    def can_manage_denomination_report
      not_authorized unless current_user.can_manage_denomination_report?
    end
end
