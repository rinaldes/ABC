class Dibeliowner < ActiveRecord::Base
  has_many :dibeliowner_details
  belongs_to :receiving
  accepts_nested_attributes_for :dibeliowner_details, :allow_destroy => true
  def self.get_number(time_now)
    "DBO/HOAsal-NamaCabang/Supplier/#{time_now.strftime("%Y/%m/%d")}/#{sprintf('%06d', (PurchaseTransfer.where("extract(year from mutation_date) = ? and extract(month from mutation_date) = ?", time_now.strftime("%Y"), time_now.strftime("%m")).last.code.last.to_i rescue 0) + 1)}"
  end
end