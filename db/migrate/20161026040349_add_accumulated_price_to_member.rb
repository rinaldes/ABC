class AddAccumulatedPriceToMember < ActiveRecord::Migration
  def change
    add_column :members, :accumulated_price, :float
  end
end
