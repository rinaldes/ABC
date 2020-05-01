class Discount < ActiveRecord::Base
  # ihsan.husnul@kiranatama.com
  # discount_type
  Normal = 'normal'
  Fiftyfifty = '50:50'
  TanggungSupplier = 'ditanggung supplier'
  TidakAdaDiskon = 'tidak ada diskon'
  Member = 'Member'

  # ihsan.husnul@kiranatama.com
  # scope :actives, where('? BETWEEN DATE(start_date) AND DATE(end_date) AND discount_type !=?', DateTime.now.strftime('%Y-%m-%d'), TidakAdaDiskon)
  scope :actives, where('DATE(start_date) >= ? AND DATE(end_date) <= ?', DateTime.now.strftime('%Y-%m-%d'), DateTime.now.strftime('%Y-%m-%d')).order("discounts.created_at")
  scope :goods_detail_types, where(discount_type: [Discount::Normal, Discount::TanggungSupplier])
  scope :brand_types, where(discount_type: Discount::Fiftyfifty)
  scope :member_discount, where(item_type: Member.to_s)

  validates :start_date, :presence => {:message => 'harus diisi'}

  before_save :check_discount_type

  # ihsan.husnul@kiranatama.com
  def goods_detail
    Goods.find_by_id self.item_id if self.item_type==Goods.to_s
  end

  # ihsan.husnul@kiranatama.com
  def brand
    Brand.find_by_id self.item_id if self.item_type==Brand.to_s
  end

  private
  protected
  def check_discount_type
    if self.discount_type==TidakAdaDiskon
      self.percent=""
      self.start_date=DateTime.now.strftime('%Y-%m-%d')
      self.end_date=""
    end
  end
end
