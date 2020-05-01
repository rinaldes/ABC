class AddDepartmentTypeToDepartment < ActiveRecord::Migration
  def change
    add_column :m_classes, :department_type, :string
  end
end
