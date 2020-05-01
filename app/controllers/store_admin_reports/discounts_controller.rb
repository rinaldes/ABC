class StoreAdminReports::DiscountsController < ApplicationController
  def index
  	@year = params[:year]
  	@month = params[:month]
    @departments = Department.where("id IN (SELECT parent_id FROM m_classes WHERE level=1)")
    @branches = Branch.all
  end
end
