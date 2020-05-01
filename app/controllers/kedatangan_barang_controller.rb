class KedatanganBarangController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]

  add_crumb "Report", '/'
  add_crumb("Kedatangan Barang".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_account_payables_path }
  add_crumb("List".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_account_payables_path }

  def index
    @date = "#{params[:year]}-#{sprintf('%02d', params[:month].to_i)}-01".to_date
    @receivings = Receiving.where("date BETWEEN '#{@date} 00:00:00' AND '#{@date.end_of_month.strftime('%Y-%m-%d')} 23:59:59'")
    respond_to do |format|
      format.html
    end
  end

  def export
    #@supplier = AccountPayable.where("outstanding_amount > 0").select("supplier_id").group("supplier_id")
    #@tanggal = AccountPayable.where("outstanding_amount > 0").select("due_date").group("due_date")
    filename = "Kedatangan Barang.xlsx"
    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end
end