class AddSomeColumnToReceivingAndReceivingDetail < ActiveRecord::Migration
  def change
    add_column :receivings, :faktur_date, :date
    add_column :receiving_details, :supplier_qty, :integer
  end
end