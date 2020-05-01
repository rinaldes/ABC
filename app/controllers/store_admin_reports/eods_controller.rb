class StoreAdminReports::EodsController < ApplicationController
  def index
    @date = (params[:year] + "-" + params[:month] + "-01").to_time if params[:month].present? && params[:year].present?
    conditions = []
    conditions << "account_payables.due_date BETWEEN '#{@date}' AND  '#{@date + 1.month}'" if params[:month].present? && params[:year].present?
    @tanggal = AccountPayable.where("outstanding_amount > 0").where(conditions.join(' AND ')).select("due_date, sum(total_amount) as total_amount2").group("due_date").order(:due_date)
    @receivings = AccountPayableReceiving.joins(:receiving, :account_payable).where("account_payables.outstanding_amount>0").where(conditions.join(' AND '))
    @receivings_per_department = @receivings.map{|a|(a.receiving.receiving_details.first.product_size.product.department rescue nil)}.compact.uniq
    @discount_percents = SalesDetail.where("discount>0 AND transaction_date BETWEEN '#{params[:year]}-#{sprintf('%02d', params[:month].to_i)}-#{sprintf('%02d', params[:date].to_i)} 00:00:00'
      AND '#{params[:year]}-#{sprintf('%02d', params[:month].to_i)}-#{sprintf('%02d', params[:date].to_i)} 23:59:59'").joins(:sale, product_size: :product)
    @sales_details = SalesDetail.where("transaction_date BETWEEN '#{params[:year]}-#{sprintf('%02d', params[:month].to_i)}-#{sprintf('%02d', params[:date].to_i)} 00:00:00'
      AND '#{params[:year]}-#{sprintf('%02d', params[:month].to_i)}-#{sprintf('%02d', params[:date].to_i)} 23:59:59'").joins(:sale, product_size: :product)
    respond_to do |format|
      format.html
    end
  end
end
