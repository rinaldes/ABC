class AddRedeemAmtToMember < ActiveRecord::Migration
  def change
    add_column :members, :reedem_amount, :float
  end
end
