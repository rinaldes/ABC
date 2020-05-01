class CreateDibeliowners < ActiveRecord::Migration
  def change
    create_table :dibeliowners do |t|
      t.string :code
      t.date :date
      t.string :status
      t.integer :pr_id
      t.string :note
      t.string :barcode
      t.timestamps
    end
  end
end