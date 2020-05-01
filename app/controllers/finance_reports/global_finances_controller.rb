class FinanceReports::GlobalFinancesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :can_manage_global_finance_report, only: [:index]
  before_filter :prepare_global_finances, only: [:index, :export]

  add_crumb "Finance", '/'
  add_crumb("Global Finance Report".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_global_finances_path }
  add_crumb("List".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_global_finances_path }

  def index
    respond_to do |format|
      format.js
      format.html
    end
  end

  def export
    filename = "Global Finance Report.xlsx"
    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end

  private
    def prepare_global_finances
      @tahunnya = (params[:year].blank?) ? Time.now.to_date.year : params[:year]
      @bulannya = (params[:month].blank?) ? Time.now.to_date.month : params[:month]
      @time = Time.now
      @branchs = Branch.all
      @tanggal = (params[:month].blank? && params[:year].blank?) ? Time.now.to_date.strftime("%B %Y") : ("1" + "-" + params[:month] + "-" + params[:year]).to_date.strftime("%B %Y")
      date = (params[:month].blank? && params[:year].blank?) ? Time.now.to_date : ("1" + "-" + params[:month] + "-" + params[:year]).to_date
      date_range = date.beginning_of_month..date.end_of_month
      @dates = date_range.map {|d| Date.new(d.year, d.month, d.day) }.uniq
      @dates.map {|d| d.strftime "%d-%m-%Y" }
    end

    def can_manage_global_finance_report
      not_authorized unless current_user.can_manage_global_finance_report?
    end
end
