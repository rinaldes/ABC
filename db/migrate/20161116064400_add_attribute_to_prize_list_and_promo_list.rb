class AddAttributeToPrizeListAndPromoList < ActiveRecord::Migration
  def change
    add_column :promo_item_lists, :reference_product_id, :integer
    add_column :prize_lists, :prize_promo, :float
    add_column :prize_lists, :disc_amt, :float
  end
end