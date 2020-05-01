class Branch < Office
  has_many :good_transfers
  has_many :product_details, class_name: 'ProductDetail', primary_key: 'id', foreign_key: 'warehouse_id'
  belongs_to :head_office

end