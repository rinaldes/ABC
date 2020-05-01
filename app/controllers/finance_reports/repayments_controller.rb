class FinanceReports::RepaymentsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :prepare_repayments, only: [:index, :export]
  before_filter :can_manage_repayment_report, only: [:index]

  add_crumb "Finance", '/'
  add_crumb("Repayment Report".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_repayments_path }
  add_crumb("List".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_repayments_path }

  def index
  end

  def export
    filename = "Repayment Report.xlsx"
    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end

  private
    def prepare_repayments
      @suppliers = Supplier.all
      @supplier_id = params[:supplier_id]
      @supplier = Supplier.find_by_id(@supplier_id)
      @results = AccountPayable.get_report_repayments(@supplier_id)
      account_payable_receivings = AccountPayableReceiving.where("account_payable_id IN (?)", @results.pluck(:id))
      @account_payable_ids = account_payable_receivings.pluck(:account_payable_id).uniq
      @other_charges_name = OtherCharge.where("account_payable_id IN (?)", @results.pluck(:id)).pluck(:name).uniq
      @repayments = Receiving.where("id IN (?)", account_payable_receivings.pluck(:receiving_id).uniq).page(params[:page]).per(PER_PAGE).order('created_at DESC')
      if @results.first.present?
        return_supplier_id = @results.first.account_payable_returns_to_suppliers.pluck(:returns_to_supplier_id)
        @returns_to_suppliers = ReturnsToSupplier.where("id IN (?)", return_supplier_id)
      end
      account_payable_details = AccountPayableDetail.get_repayment_detail(@account_payable_ids)
      @cash = account_payable_details[0]
      @transfer = account_payable_details[1]
      @giro = account_payable_details[2]
      @rowspan = @repayments.count
    end

    def can_manage_repayment_report
      not_authorized unless current_user.can_manage_repayment_report?
    end
end
