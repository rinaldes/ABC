class ReportTransferanController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]

  add_crumb "Report", '/'
  add_crumb("Transferan Barang".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_account_payables_path }
  add_crumb("List".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_account_payables_path }

  def index
    #@tanggal = AccountPayable.where("outstanding_amount > 0").select("due_date, sum(total_amount) as total_amount2").group("due_date").order(:due_date)
    @branches = Branch.all
    @u_receive = ReceivePurchaseTransfer.where("receiving_id is null").joins(:purchase_transfer).where("mutation_date BETWEEN '#{params[:year]}-#{params[:month]}-01 00:00:00' AND '#{"#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month.strftime('%Y-%m-%d 23:59:59')}'")
    @receivings = Receiving.where("date BETWEEN '#{params[:year]}-#{params[:month]}-01 00:00:00' AND '#{"#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month.strftime('%Y-%m-%d 23:59:59')}'")
    @receiving_details = ReceivingDetail.where("receivings.date BETWEEN '#{params[:year]}-#{params[:month]}-01 00:00:00' AND '#{"#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month.strftime('%Y-%m-%d 23:59:59')}'").joins(:receiving)
    @monthly_receivings = @receiving_details.group_by{|r|r.receiving.date.strftime('%B')}
    filename = "Receiving"
    filename << " #{params[:month]}/#{params[:year]}" if params[:month].present? && params[:year].present?
    respond_to do |format|
      format.html
      format.xls
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}.xlsx\"" }
    end
  end

  def export
    #@supplier = AccountPayable.where("outstanding_amount > 0").select("supplier_id").group("supplier_id")
    #@tanggal = AccountPayable.where("outstanding_amount > 0").select("due_date").group("due_date")
    filename = "Report Transferan.xlsx"
    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end
end