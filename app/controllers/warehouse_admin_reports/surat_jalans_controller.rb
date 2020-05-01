class WarehouseAdminReports::SuratJalansController < ApplicationController
  def index
    @dates = 1.upto("#{Time.now.month} #{Time.now.year}" == "#{params[:month]} #{params[:year]}" ? Time.now.strftime("%d").to_i : "#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month.strftime("%d").to_i)
  end
end
