class StockTransferDetail < ActiveRecord::Base
	belongs_to :stock_transfer
	belongs_to :product
	belongs_to :product_size, foreign_key: 'product_detail_id'
end
