class Supplier < ActiveRecord::Base
#  include Filter
  JOIN = ''
  ORDER = 'suppliers.id'
  SELECTED = 'suppliers.*'
  GROUP_BY = 'suppliers.id'

  before_validation :upcase_save

  before_destroy :check_transaction

  has_many :brands
  has_many :purchase_orders
  has_many :returns_to_suppliers
  has_many :returns_to_supplier_details, :through => :returns_to_suppliers
  has_many :goods, through: :brands
  has_many :goods_receipts
  has_many :composite_purchase_orders
  has_many :contact_people, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy
  has_many :purchase_requests
  has_many :supplier_departments, dependent: :destroy
  has_many :departments, class_name: 'MClass', through: :supplier_departments
  has_many :account_payables

  accepts_nested_attributes_for :supplier_departments, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true
  validates :address, :presence => true
#  validates :city, :presence => true
#  validates_format_of :name, :with => /^[a-zA-Z\d\s]*$/i, :multiline => true, :message => "can be inputted by alphabet only"
  validates_format_of :city, :with => /^[a-zA-Z\d\s]*$/i, :multiline => true, :message => "hanya mengijinkan input alphabet"

#  validate :at_least_one_cp

  accepts_nested_attributes_for :contact_people, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :bank_accounts, reject_if: :all_blank, allow_destroy: true

  scope :search, lambda {|search|{
    :order => "code ASC",
    :conditions => [
      'code LIKE ? OR name LIKE ? OR send_address LIKE ? OR city LIKE ? OR phone LIKE ? OR hp1 LIKE ? OR pinbb LIKE ? OR email LIKE ?',
      "%#{search.first}%", "%#{search.first}%", "%#{search.first}%", "%#{search.first}%", "%#{search.first}%", "%#{search.first}%",
      "%#{search.first}%", "%#{search.first}%"
    ]
  }}

  def at_least_one_cp
    errors.add(:contact_person, "can't be blank") if contact_people.blank?
  end

  def check_transaction
    return false if Brand.find_by_supplier_id id
    true
  end

  def self.number(params)
    number = (Supplier.first(:conditions => "name like '#{params[:first_char]}%'", :order => "id DESC").code[1..-1].to_i rescue 0)+1
    return number
  end

  def self.create_number(params)
    init = params[:supplier][:name][0]
    number = (Supplier.first(:conditions => "name like '#{init}%'", :order => "id DESC").code[1..-1].to_i rescue 0)+1
    return number
  end


  def self.get_supplier_id(supplier)
    id = (Supplier.first(:conditions => "code = '#{supplier}' or name = '#{supplier}'", :order => "id DESC").id.to_i rescue 0)
    return id
  end

  def upcase_save
    self.name = name.titleize rescue nil
    self.address = address.titleize rescue nil
    self.city = city.titleize rescue nil
    self.long_term = nil if suptype == 'Konsinyasi'
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["Code", "Name", "Address", "City", "Send Address", "Phone", "Fax", "Long Term", "Suptype", "Contact Person", "No HP", "Pin BB", "Email", "Nama Rekening Bank", "No Rekening", "Bank", "Cabang", "Kota", "Department"]
      all.each do |supplier|
        phone = supplier.phone.first == '0' ? "'#{supplier.phone}" : supplier.phone
        first_cp = supplier.contact_people.first
        if first_cp.present?
          cp_phone = first_cp.phone.first == '0' ? "'#{first_cp.phone}" : first_cp.phone
        end
        supp = [supplier.code, supplier.name, supplier.address, supplier.city, supplier.send_address, phone, supplier.fax, supplier.long_term, supplier.suptype]
        supp += [(first_cp.name rescue ''), cp_phone, (first_cp.pinbb rescue ''), (first_cp.email rescue nil)]
        first_ba = supplier.bank_accounts.first
        supp += [(first_ba.name rescue ''), (first_ba.account_number rescue ''), (first_ba.bank_name rescue ''), (first_ba.branch rescue ''), (first_ba.city rescue '')]
        supp += [(supplier.departments.first.name rescue nil)]

        csv << supp
        1.upto([supplier.bank_accounts.length, supplier.contact_people.length, supplier.departments.length].max-1) do |i|
          cp = supplier.contact_people[i]
          ba = supplier.bank_accounts[i]
          sd = supplier.departments[i]
          supp = ['', '', '', '', '', '', '', '']
            cp_phone = cp.phone.first == '0' ? "'#{cp.phone}" : cp.phone
          if cp.present?
          end
          supp += [(cp.name rescue ''), (cp.phone rescue ''), (cp.pinbb rescue ''), (cp.email rescue '')]
          supp += [(ba.name rescue ''), (ba.account_number rescue ''), (ba.bank_name rescue ''), (ba.branch rescue ''), (ba.city rescue '')]
          supp += [sd.name] if sd.present?
          csv << supp
        end
      end
    end
  end

  def self.to_csv2(options = {})
    CSV.generate(options) do |csv|
      csv << ["Name", "Address", "City", "Send Address", "Phone", "Fax", "Long Term", "Suptype", "Contact Person", "No HP", "Pin BB", "Email", "Nama Rekening Bank", "No Rekening", "Bank", "Cabang", "Kota",
        "Department"]
    end
  end

  def self.import(file)
    line = 0
    $NAMANYA = ''
    CSV.foreach(file.path, headers: true) do |row|
      if row.to_hash["name"].present?
        $NAMANYA = row[0]
        $SUPPLIER = Supplier.new(name: row[0], address: row[1] || 'TBD', city: row[2], send_address: row[3], phone: row[4], fax: row[5], long_term: row[6], suptype: row[7] == '1' ? 'Konsinyasi' : 'Non-Konsinyasi',
          code: row.to_hash["code"])
        if $SUPPLIER.save
          ContactPerson.create(name: row[8], phone: row[9], pinbb: row[10], email: row[11], supplier_id: $SUPPLIER.id)
          BankAccount.create(name: row[12], account_number: row[13], bank_name: row[14], branch: row[15], city: row[16], supplier_id: $SUPPLIER.id)
          SupplierDepartment.create(
            supplier_id: $SUPPLIER.id, department_id: Department.where(name: row[17].titleize).first_or_create.id
          ) if row[17].present?
          line += 1
        else
          return {error: 1, message: line == 0 ? "Import failed, please recheck CSV file. #{$SUPPLIER.errors.full_messages.join('<br/>')}" : "Successfully imported until line #{line}. Failed imported  from line #{line+1}. Please recheck and reupload from line #{line+1}. #{$SUPPLIER.errors.full_messages.join('<br/>')}"}
        end
      else
        id_sup = $SUPPLIER.id
        ContactPerson.create(name: row[8], phone: row[9], pinbb: row[10], email: row[11], supplier_id: id_sup)
        BankAccount.create(name: row[12], account_number: row[13], bank_name: row[14], branch: row[15], city: row[16], supplier_id: id_sup)
        SupplierDepartment.create(supplier_id: id_sup, department_id: Department.where(name: row[17].titleize).first_or_create.id) if row[17].present?
      end
    end
    return {error: 0, message: "Successfully imported"}
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
