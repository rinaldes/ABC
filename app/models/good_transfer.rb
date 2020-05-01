class GoodTransfer < ProductMutation
  validates_presence_of [:origin_warehouse_id, :destination_warehouse_id]
  
  def self.get_number(time_now)
    "M/ho-cabang/supplier/#{time_now.strftime("%Y-%m-%d")}/#{
      sprintf('%06d',
        (GoodTransfer.where("extract(year from date) = ? and extract(month from date) = ?", time_now.strftime("%Y"), time_now.strftime("%m")).last.number.split('-')[1].to_i rescue 0) + 1)
    }"
  end

end
