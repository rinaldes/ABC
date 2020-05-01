class AddBtpMasukToSales < ActiveRecord::Migration
  def change
    add_column :sales, :btp_masuk, :float
    add_column :sales, :btp_keluar, :float
  end
end
