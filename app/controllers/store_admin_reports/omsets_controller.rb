class StoreAdminReports::OmsetsController < ApplicationController
  def index
    @year = params[:year]
    @month = params[:month]
    conditions = []
    conditions << "id=#{params[:id]}" if params[:id].present?
    @departments = Department.where("id IN (SELECT parent_id FROM m_classes WHERE level=1)")
    @branches = Branch.where(conditions.join(' AND '))
    @suppliers = Supplier.all
    filename = "Omset per Supplier #{Date::MONTHNAMES[params[:month].present? ? params[:month].to_i : Time.now.month]} #{params[:year].present? ? params[:year] : Time.now.year}"
    respond_to do |format|
      format.html
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}.xlsx\"" }
    end
#    @sales = SalesDetail.where("quantity > 0 AND transaction_date BETWEEN '#{params[:year]}-#{sprintf('%02d', params[:month].to_i)}-01 00:00:00' AND
 #     '#{"#{params[:year]}-#{sprintf('%02d', params[:month].to_i)}-01".to_date.end_of_month.strftime('%Y-%m-%d')} 23:59:59'").joins(:sale)
  end
end
