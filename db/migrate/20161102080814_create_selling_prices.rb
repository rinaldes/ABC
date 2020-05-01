class CreateSellingPrices < ActiveRecord::Migration
  def change
    create_table :selling_prices do |t|
			t.string :code
		  t.integer :product_id
		  t.float :margin
		  t.float :hpp
		  t.float :dpp
		  t.float :ppn_in
		  t.float :ppn_out
		  t.date :start_date
		  t.date :end_date
		  t.integer :branch_id
		  t.integer :office_id
		  t.float :selling_price
		  t.float :margin_amount
		  t.boolean :is_active
		  t.float :hpp_2
		  t.integer :receiving_id
		  t.float :margin_percent
		  t.float :hpp_average
		  t.integer :supplier_id
		  t.string :price_type
      t.timestamps
    end
  end
end
