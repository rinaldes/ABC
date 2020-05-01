class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.integer :user_id
      t.integer :shift_no
      t.timestamps
      t.time :start_time
      t.time :end_time
      t.integer :office_id
      t.string :client_id
      t.integer :sodeod_id
    end
  end
end
