class FinanceReports::SisaHutangDagangController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :prepare_account_payables, only: [:index, :export]
  before_filter :can_manage_account_payable_report, only: [:index]

  add_crumb "Finance", '/'
  add_crumb("Sisa Hutang Dagang".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_account_payables_path }
  add_crumb("List".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_account_payables_path }

  def index
    @date = (params[:year] + "-" + params[:month] + "-01").to_time if params[:month].present? && params[:year].present?
    conditions = []
    conditions << "account_payables.due_date BETWEEN '#{@date}' AND  '#{@date + 1.month}'" if params[:month].present? && params[:year].present?
    @tanggal = AccountPayable.where("outstanding_amount > 0").where(conditions.join(' AND ')).select("due_date, sum(total_amount) as total_amount2").group("due_date").order(:due_date)
    @receivings = AccountPayableReceiving.joins(:receiving, :account_payable).where("account_payables.outstanding_amount>0").where(conditions.join(' AND '))
    @receivings_per_department = @receivings.map{|a|(a.receiving.receiving_details.first.product_size.product.department.department_type rescue nil)}.compact.uniq
    respond_to do |format|
      format.html
    end
  end

  def export
    @date = (params[:year] + "-" + params[:month] + "-01").to_time if params[:month].present? && params[:year].present?
    conditions = []
    conditions << "account_payables.due_date BETWEEN '#{@date}' AND  '#{@date + 1.month}'" if params[:month].present? && params[:year].present?
    @tanggal = AccountPayable.where("outstanding_amount > 0").where(conditions.join(' AND ')).select("due_date, sum(total_amount) as total_amount2").group("due_date").order(:due_date)
    @receivings = AccountPayableReceiving.joins(:receiving, :account_payable).where("account_payables.outstanding_amount>0").where(conditions.join(' AND '))
    @receivings_per_department = @receivings.map{|a|(a.receiving.receiving_details.first.product_size.product.department rescue nil)}.compact.uniq
    filename = "Sisa Hutang Dagang.xlsx"
    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end

  private
    def prepare_account_payables
      @account_payables = AccountPayable.get_report
    end

    def can_manage_account_payable_report
      not_authorized unless current_user.can_manage_account_payable_report?
    end
end
