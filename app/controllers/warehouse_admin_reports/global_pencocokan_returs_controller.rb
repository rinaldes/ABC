class WarehouseAdminReports::GlobalPencocokanRetursController < ApplicationController
  def index
    @branches = Branch.all
    @returns_to_hos = ReturnsToHo.all.group_by{|rth|rth.origin_warehouse_id}
    respond_to do |format|
      format.html
      format.xls
    end
  end
end
