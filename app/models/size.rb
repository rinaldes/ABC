class Size < ActiveRecord::Base
  has_many :size_details, dependent: :destroy
  #has_many :goods, class_name: "Goods", dependent: :destroy

  accepts_nested_attributes_for :size_details, reject_if: :all_blank, allow_destroy: true

  validates :description, presence: true, uniqueness: true
#  validates_format_of :description, :with => /^[a-zA-Z\d\s-]*$/i, :multiline => true, :message => "hanya mengijinkan input alphabet"
  #validates :size_details, presence: true
  #validate :check_detail

  scope :search, lambda {|search|{
    joins: "JOIN size_details ON size_details.size_id = sizes.id", order: "code ASC",
    conditions: ['description LIKE ? OR size_number LIKE ? OR code LIKE ?', "%#{search.first}%", "%#{search.first}%", "%#{search.first}%"]
  }}

  before_validation :set_titleize

  def check_transaction
    return false if Product.find_by_size_id(self.id)
    true
  end

  def set_titleize
    self.description = description.titleize rescue nil
  end

  def sorted_size_details
    size_details.sort_by{|size|
      number = size.size_number
      number.upcase == 'XS' ? 0 : number.upcase == 'S' ? 1 : number.upcase == 'M' ? 2 : number.upcase == 'L' ? 3 : number.upcase == 'XL' ? 4 : number.upcase == 'XXL' ? 5 : number.upcase == 'XXXL' ? 6 : number.upcase == 'ALL SIZE' ? 777 : number.to_i
    }
  end

  def check_detail
    errors.add(:size_details, " harus diisi minimal 1 ukuran detail") if size_details.blank? 
  end

  def check_relation
    return goods_already_in_used 
  end

  def size_details_is_valid?
    size_com = size_details.compact
    if size_com.length >= 1
      size_asli = self.size_details.map{|k,v| k["size_number"]}
      size_uniq = size_asli.uniq
      size_order = size_asli

      if size_uniq == size_asli
        size_order = size_order.sort_by{|v| v.to_f}
        if size_asli != size_order
          errors.add(:base, "Data Size tidak berurutan")
        end
      else
        errors.add(:base, "Data size duplikat")
      end
    end
  end

  def goods_already_in_used
    return goods.count != 0 ? false:true
  end

  def self.number(params)
    number = (Size.first(:conditions => "description like '#{params[:first_char]}%'", :order => "id DESC").code[1..-1].to_i rescue 0)+1
    return number
  end

  def self.create_number(params)
    number = (Size.first(:conditions => "description like '#{init}%'", :order => "id DESC").code[1..-1].to_i rescue 0)+1
    return number
  end

  def self.get_size_id(size)
    id = (Size.first(:conditions => "code = '#{size}' or description = '#{size}'", :order => "id DESC").id.to_i rescue 0)
    return id
  end

  def manage_code
    if  self.new_record?
      if self.class.unscoped.available_data.present?
        (('%03d' % ((self.class.unscoped.available_data.order("id ASC").last.code.to_i rescue 0))))
      else
        (('%03d' % ((self.class.order("code ASC").last.code.to_i rescue 0)+1)))
      end
    else
      self.code
    end
  end

  def self.import(file)
    line = 0
    CSV.foreach(file.path, headers: true) do |row|
      if find_by_description(row["description"].upcase).nil?
        parameters = ActionController::Parameters.new(row.to_hash)
        size = new(parameters.permit(:description).merge(code: (("S#{'%03d' % ((Size.last.code.last.to_i rescue 0)+1)}"))))
        if size.save
          if row["description"] == "All Size"
            s_detail = SizeDetail.new(size_id: size.id, size_number: "All Size")
            s_detail.save
          else
            t = 1
            15.times do 
              s_detail = SizeDetail.new(size_id: size.id, size_number: row[t]) if row[t].present?
              t += 1
              s_detail.save if row[t].present?
            end
          end
        else
          return {error: 1, message: line == 0 ? "Import failed, please recheck CSV file. #{size.errors.full_messages.join('<br/>')}" : "Successfully imported until line #{line}. Failed imported  from line #{line+1}. Please recheck and reupload from line #{line+1}. #{size.errors.full_messages.join('<br/>')}"}
        end
        line += 1
      else
        return {error: 0, message: "Successfully imported"}
      end
    end
    return {error: 0, message: "Successfully imported"}
  end

end