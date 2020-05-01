class AddOfficeIdMClassIdDepartmentId < ActiveRecord::Migration
  def change
    add_column :budgets, :office_id, :integer
    add_column :budgets, :m_class_id, :integer
    add_column :budgets, :department_id, :integer
  end
end