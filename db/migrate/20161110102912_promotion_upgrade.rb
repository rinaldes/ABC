class PromotionUpgrade < ActiveRecord::Migration
  def change
    change_column :promotions, :multi, 'boolean USING CAST(multi AS boolean)'
    add_column :promotions, :is_member, :boolean
    add_column :promotions, :is_p2p, :boolean
    add_column :promotions, :is_claim, :boolean
    add_column :promotions, :promotion_type, :string
  end
end