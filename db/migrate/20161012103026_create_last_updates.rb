class CreateLastUpdates < ActiveRecord::Migration
  def change
    create_table :last_updates do |t|
    	t.datetime :sync_date
      t.timestamps
    end
  end
end
