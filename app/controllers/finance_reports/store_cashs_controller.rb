class FinanceReports::StoreCashsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :parent_store_cash, only: [:index, :export]
  before_filter :prepare_store_cashs, only: [:index]
  before_filter :can_manage_store_cash_report, only: [:index]

  add_crumb "Finance", '/'
  add_crumb("Store Cash Report".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_store_cashs_path }
  add_crumb("List".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_store_cashs_path }

  def index
  end

  def export
    filename = "Store Cash Report.xlsx"
    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end

  private
    def parent_store_cash
      @offices = Office.all
      @year = params[:date].blank? ? Date.today.year : params[:date][:year]
      @month = params[:date].blank? ? Date.today.month : params[:date][:month]
      @petty_cash = PettyCash.joins(:office).where("EXTRACT(YEAR FROM year) = ?", @year).where("EXTRACT(MONTH FROM year) = ?", @month)
    end

    def prepare_store_cashs
      @petty_cash = @petty_cash.where("offices.id = ?", params[:office_id]).first
      if @petty_cash.present?
        @cash_outs = @petty_cash.cash_outs.where("cash_out_type != 'CASH IN'")
        @cash_out_types = @cash_outs.pluck(:cash_out_type).uniq
      end
    end

    def can_manage_store_cash_report
      not_authorized unless current_user.can_manage_store_cash_report?
    end
end
