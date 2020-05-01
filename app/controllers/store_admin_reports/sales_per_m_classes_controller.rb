class StoreAdminReports::SalesPerMClassesController < ApplicationController
  def index
    params[:start_date] = 1 if params[:start_date].blank?
    params[:end_date] = "#{params[:year]}-#{sprintf('%02d', params[:month])}-#{params[:start_date]}".to_datetime.end_of_month.day if params[:end_date].blank?
    @sales_details = SalesDetail.where("transaction_date BETWEEN '#{params[:year]}-#{sprintf('%02d', params[:month])}-#{sprintf('%02d', params[:start_date])} 00:00:00' AND '#{params[:year]}-#{sprintf('%02d', params[:month])}-#{params[:end_date]} 23:59:59'").joins(:sale)
    @departments = Department.where("id IN (SELECT parent_id FROM m_classes WHERE level=1)")
    @branches = Branch.all
  end
end
