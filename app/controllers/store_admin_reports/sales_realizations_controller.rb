class StoreAdminReports::SalesRealizationsController < ApplicationController
  def index
    @branches = Branch.all
    @role = Role.find_by_name("SPG")
    @users = User.where(role_id: @role.id)
    @month = params[:month]
    @year = params[:year]
    filename = "Sales Realization #{Date::MONTHNAMES[params[:month].present? ? params[:month].to_i : Time.now.month]} #{params[:year].present? ? params[:year] : Time.now.year}"
    respond_to do |format|
      format.html
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}.xlsx\"" }
    end
  end
end
