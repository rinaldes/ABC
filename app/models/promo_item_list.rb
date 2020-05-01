class PromoItemList < ActiveRecord::Base
  belongs_to :promotion
  belongs_to :m_class
  belongs_to :brand
  belongs_to :department
  belongs_to :product
end
