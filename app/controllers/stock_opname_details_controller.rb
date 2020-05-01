class StockOpnameDetailsController < ApplicationController

  def import
#    redirect_to edit_stock_opname_url(params[:id]), notice: StockOpnameDetail.import(params[:file], params[:id])
    respond_to do |format|
      format.html {send_data StockOpnameDetail.import(params[:file], params[:id])}
    end
  end

  def index
    respond_to do |format|
      format.xls
      if(params[:a] == "a")
        format.csv { send_data StockOpnameDetail.all.to_csv2 }
      else
        format.csv { send_data StockOpnameDetail.all.to_csv }
      end
    end
  end

end