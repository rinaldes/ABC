class Office < ActiveRecord::Base
  belongs_to :user, foreign_key: :contact_person
  before_validation :upcase_save

  has_many :promotions
  has_many :petty_cashes

  has_many :office_departments, :dependent => :destroy
  has_many :departments, :through => :office_departments

  has_many :sod_eods
  has_many :account_receivables

  has_many :branch_to_do_lists, :dependent => :destroy
	has_many :to_do_lists, through: :branch_to_do_lists

  accepts_nested_attributes_for :office_departments, reject_if: :all_blank, allow_destroy: true

  validates :office_name, :presence => true, :uniqueness => true
  validates :description, :presence => true
  validates :warehouse, :presence => true
  validates :address, :presence => true
  validates :mobile_phone, :presence => true
  validates :phone_number, :presence => true
  validates :fax_number, :presence => true
  validates :contact_person, presence: {:message => "Penanggung Jawab tidak diketahui"}
  validates_format_of :office_name, :with => /^[a-zA-Z\d\s]*$/i, :multiline => true, :message => "hanya mengijinkan input alphabet"
  validates_format_of :description, :with => /^[a-zA-Z\d\s]*$/i, :multiline => true, :message => "hanya mengijinkan input alphabet"
  validates_format_of :warehouse, :with => /^[a-zA-Z\d\s]*$/i, :multiline => true, :message => "hanya mengijinkan input alphabet"
  validates_format_of :address, :with => /^[a-zA-Z\d\s.,-]*$/i, :multiline => true, :message => "hanya mengijinkan input alphabet"

  after_create :generate_product_details

  def upcase_save
    self.office_name = office_name.last == ' ' ? office_name.chop.titleize : office_name.titleize rescue nil
  end

  def check_transaction
    return false if User.find_by_head_office_id(self.id) || User.find_by_branch_id(self.id) || ProductDetail.where("warehouse_id=#{self.id} AND available_qty>0").limit(1).present? || Branch.find_by_head_office_id(self.id)
    true
  end

  def generate_product_details
    ProductDetail.all.each{|product_detail|
      ProductDetail.where(product_size_id: product_detail.product_size_id, warehouse_id: id, min_stock: product_detail.min_stock).first_or_create
    }
  end

  def self.import(file, tipe)
    line = 0
    current_office = 0
    CSV.foreach(file.path, headers: true) do |row|
      if row["office_name"].present?  
        if find_by_office_name(row["office_name"].upcase).nil?
          parameters = ActionController::Parameters.new(row.to_hash)
          office = new(parameters.permit(:office_name, :type, :description, :warehouse, :phone_number, :fax_number, :mobile_phone, :address, :short_address)
            .merge(:contact_person => User.find_by_username(row["username"]).i, head_office_id: (Office.find_by_office_name(row["head_office"]).id rescue nil)))
          if office.save
            t = 7
            14.times { 
              off_dep = OfficeDepartment.new(office_id: office.id, department_id: t)
              off_dep.save
              t += 1
               }
          else
            return {error: 1, message: line == 0 ? "Import failed, please recheck CSV file. #{office.errors.full_messages.join('<br/>')}" : "Successfully imported until line #{line}. Failed imported  from line #{line+1}. Please recheck and reupload from line #{line+1}. #{office.errors.full_messages.join('<br/>')}"}
          end
          line += 1
        else
          return {error: 0, message: "Successfully imported"}
        end
      else

      end
    end
    return {error: 0, message: "Successfully imported"}
  end
end