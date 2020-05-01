class FinanceReports::ReportAzzurraController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :prepare_account_payables, only: [:index, :export]
  before_filter :can_manage_account_payable_report, only: [:index]

  add_crumb "Finance", '/'
  add_crumb("Azzurra Report".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_account_payables_path }
  add_crumb("List".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_account_payables_path }

  def index
    date = ((params[:year].present? ? params[:year] : Time.now.year.to_s) + '-' + (params[:month].present? ? params[:month] : Time.now.month.to_s) + '-01').to_time
    conditions = []
    conditions << "product_mutations.mutation_date BETWEEN '#{date}' AND  '#{date + 1.month}'"
    @r_azzurra_ke_abc = ProductMutationDetail.joins(:product_mutation).where(conditions.join(' AND ')).where("product_mutations.origin_warehouse_id = #{6} AND product_mutations.type = 'ReturnsToHo'")
    @abc_ke_azzurra = PurchaseTransfer.where(conditions.join(' AND ')).where("product_mutations.destination_warehouse_id = #{6}")
    
    conditions = []
    conditions << "date BETWEEN '#{date}' AND  '#{date + 1.month}'"
    @azzurra_ke_abc = ReceivingDetail.joins(receiving: :supplier).where(conditions.join(' AND ')).where("lower(suppliers.name) like '%azzurra%'")
    @azzurra_bon = Receiving.joins(:supplier).where(conditions.join(' AND ')).where("lower(suppliers.name) like '%azzurra%'")

    conditions = []
    conditions << "returns_to_suppliers.date BETWEEN '#{date}' AND  '#{date + 1.month}'"
    @r_abc_ke_azzurra = ReturnsToSupplierDetail.joins(returns_to_supplier: :supplier).where(conditions.join(' AND ')).where("lower(suppliers.name) like '%azzurra%'")
    
    filename = "Azzurra Report " + date.strftime("%B %Y") + ".xlsx"
    respond_to do |format|
      format.html
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end

  def export
    @supplier = AccountPayable.where("outstanding_amount > 0").select("supplier_id").group("supplier_id")
    @tanggal = AccountPayable.where("outstanding_amount > 0").select("due_date").group("due_date")
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
