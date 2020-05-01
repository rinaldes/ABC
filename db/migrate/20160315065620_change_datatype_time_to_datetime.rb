class ChangeDatatypeTimeToDatetime < ActiveRecord::Migration
  def change
  	remove_column :cash_outs, :time
  	add_column :cash_outs, :time, :datetime
  end
end
