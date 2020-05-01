class StoreAdminReports::RevenuesController < ApplicationController
  def index
    @departments = Department.where("id IN (SELECT parent_id FROM m_classes WHERE level=1)")
    @branches = Branch.all
  end
end
