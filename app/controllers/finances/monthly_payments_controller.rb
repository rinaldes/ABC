class Finances::MonthlyPaymentsController < ApplicationController
  def index
    @giro = "payment_date BETWEEN '#{params[:year]}-#{params[:month]}-01' AND  '#{params[:year]}-#{params[:month].to_i+1}-01' AND method='Giro'"
    @payments_by_giro = AccountPayableDetail.where(@giro).select("payment_date").group("payment_date").select("SUM(amount) AS amount")#collect per bulan yang tipenya giro
    #loop per tanggal
    @payments_by_cash_and_trf = AccountPayableDetail.where("payment_date BETWEEN '#{params[:year]}-#{params[:month]}-01' AND  '#{params[:year]}-#{params[:month].to_i+1}-01' AND method IN ('Cash', 'Transfer')")
      #collect per bulan yang tipenya cash and transfer
    filename = "Monthly Payment"
    filename << " #{params[:month]}/#{params[:year]}" if params[:month].present? && params[:year].present?
    @period = (params[:year] + "-" + params[:month] + "-01").to_date.strftime('%B %Y') rescue Time.now.strftime('%B %Y')
    respond_to do |format|
      format.html
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}.xlsx\"" }
    end
  end
end
