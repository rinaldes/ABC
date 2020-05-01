class CreateSodEodFields < ActiveRecord::Migration
  def change
    create_table :sod_eod_fields do |t|
      t.integer :sod_eod_id
      t.string :description
      t.float :value
      t.timestamps
    end
  end
end
