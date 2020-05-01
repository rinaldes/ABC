class CreatePettyCashTypes < ActiveRecord::Migration
  def change
    create_table :petty_cash_types do |t|
      t.string :code
      t.string :name
      t.timestamps
    end
  end
end
