class MClass < ActiveRecord::Base
  belongs_to :m_class, foreign_key: :parent_id
  has_many :m_classes, foreign_key: :parent_id, dependent: :destroy

  validates :name, presence: {:message => 'harus diisi'}
  validate :check_name_and_parent_id, on: [:destroy, :create]

  before_save :set_tree

  before_validation :set_titleize

#  before_destroy :check_transaction

  def check_transaction
    return false if MClass.find_by_parent_id_and_level(self.id, 1)
    return false if SupplierDepartment.find_by_department_id(self.id) || Brand.find_by_department_id(self.id) || Product.find_by_m_class_id(self.id)
    lv2 = MClass.where("parent_id=#{self.id}").map(&:id).join(',')
    return true if lv2.blank?
    return false if Product.where("m_class_id IN (#{lv2})").present?
    lv3 = MClass.where("parent_id IN (#{lv2})").map(&:id).join(',')
    return true if lv3.blank?
    return false if Product.where("m_class_id IN (#{lv3})").present?
    lv4 = MClass.where("parent_id IN (#{lv3})").map(&:id).join(',')
    return true if lv4.blank?
    return false if Product.where("m_class_id IN (#{lv4})").present?
    true
  end

  def check_name_and_parent_id
    errors.add(:name, "already in use") if MClass.find_by_name_and_parent_id(name, parent_id)
  end

  def set_titleize
    self.name = name.titleize rescue nil
  end

  def set_tree
    set_department_m_class self
  end

  def set_department_m_class m_class
    d_m_class = []
    current_m_class = m_class
    while current_m_class.present? do
      d_m_class << current_m_class.name
      current_m_class = current_m_class.m_class
    end
    self.department_m_class = d_m_class.join(' > ')
  end

  def set_path
    set_path_id self
    set_path_code self
  end

  def set_path_id m_class
    d_m_class = []
    current_m_class = m_class
    while current_m_class.present? do
      d_m_class << current_m_class.id
      current_m_class = current_m_class.m_class
    end
    self.path_id = d_m_class.join('>')
    self.save validate: false
  end

  def set_code
    set_path_code self
  end

  def set_path_code m_class
    d_m_class = []
    current_m_class = m_class
    while current_m_class.present? do
      d_m_class << current_m_class.code
      current_m_class = current_m_class.m_class
    end
    self.path_code = d_m_class.last
    self.save validate: false
  end

  def department
    parent_id.present? ? m_class.department : self
  end

  def code_and_name
    [code, name].join(' - ')
  end

  def parent lv
    m_class.blank? || level == lv ? self : m_class.parent(lv)
  end

  def children_size
    size = m_classes.size
    m_classes.each{|m_class|
      m_classes = m_class.m_classes
      if m_classes.present?
        size += m_class.children_size
      end
    }
    return size
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["Department", "M-Class 1", "M-Class 2", "M-Class 3", "M-Class 4"]
      all.where("parent_id is null").order("m_classes.created_at DESC").each do |depart|
        next unless MClass.find_by_parent_id(depart.id)
        par1 = depart.name
        find1 = false
        all.where(parent_id: depart.id).order('created_at ASC').each do |m_class1|
          par2 = m_class1.name
          find2 = false
          all.where(parent_id: m_class1.id).order('created_at ASC').each do |m_class2|
            par3 = m_class2.name
            find3 = false
            all.where(parent_id: m_class2.id).order('created_at ASC').each do |m_class3|
              par4 = m_class3.name
              find4 = false
              all.where(parent_id: m_class3.id).order('created_at ASC').each do |m_class4|
                csv << [par1, par2, par3, par4, m_class4.name]
                par1, par2, par3, par4 = "", "", "", ""
                find4 = true
              end
              if find4 == false
                csv << [par1, par2, par3, par4, ""]
              end
              par1, par2, par3 = "", "", ""
              find3 = true
            end
            if find3 == false
              csv << [par1, par2, par3, "", ""]
            end
            par1, par2 = ""
            find2 = true
          end
          if find2 == false
            csv << [par1, par2, "", "", ""]
          end
          par1 = ""
          find1 = true
        end
        if find1 == false
          csv << [par1, "", "", "", ""]
        end
      end
    end
  end

  def self.to_csv2(options = {})
    CSV.generate(options) do |csv|
      csv << ["Department", "M-Class 1", "M-Class 2", "M-Class 3", "M-Class 4"]
      all.each do |m_class|
      end
    end
  end

  def full_messages
    errors.full_messages.join('<br/>')
  end

  def self.import(file)
    parent, parent2, parent3, parent4, line = 0, 0, 0, 0, 0
    counter = 0
    CSV.foreach(file.path, headers: true) do |row|
      last_mclass_code = (MClass.where("level=2").limit(1).order("code DESC").last.code.chop.chop.chop.to_i rescue 0)
      unless row[0].nil?
        if MClass.find_by_name(row[0].titleize).present?
          parent = MClass.find_by_name(row[0].titleize)
        else
          return {error: 1, message: line == 0 ? "#{FlashMessage.recheck_csv}, department name is not registered in department master data" : FlashMessage.partial_import_success(line)}
        end
      end
      unless row[1].nil?
        if MClass.find_by_name(row.to_hash["M-Class 1"]).present?
          parent2 = MClass.find_by_name(row.to_hash["M-Class 1"]).id
        else
          $M_SAVE = MClass.new(:name => row[1], level: 1, parent_id: parent.id, code: "#{parent.code}#{[*('A'..'Z')][MClass.where("parent_id=#{parent.id}").count]}")
          if $M_SAVE.save
            parent2 = $M_SAVE.id
            $M_SAVE.set_path
          else
            return {error: 1, message: line == 0 ? "#{FlashMessage.recheck_csv}. #{$M_SAVE.full_messages}" : "#{FlashMessage.partial_import_success(line)}. #{$M_SAVE.errors.full_messages}"}
          end
        end
      end
      unless row[2].nil?
        counter = MClass.find_by_parent_id(parent2) ? counter+1 : 1
        if MClass.find_by_name(row.to_hash["M-Class 2"]).present?
          parent3 = MClass.find_by_name(row.to_hash["M-Class 2"])
        else
          $M2_SAVE = MClass.new(name: row[2], level: 2, parent_id: parent2, code: "#{sprintf '%03d', (MClass.find_by_parent_id(parent2) ? last_mclass_code : last_mclass_code+1)}#{sprintf '%03d', counter}")
          if $M2_SAVE.save
            parent3 = $M2_SAVE
            $M2_SAVE.set_path
          else
            return {error: 1, message: line == 0 ? "#{FlashMessage.recheck_csv}. #{$M2_SAVE.full_messages}" : "#{FlashMessage.partial_import_success(line)}. #{$M2_SAVE.full_messages}"}
          end
        end
      end
      unless row[3].nil?
        if MClass.find_by_name(row.to_hash["M-Class 3"]).present?
          parent4 = MClass.find_by_name(row.to_hash["M-Class 3"])
        else
          $M3_save = MClass.new(
            name: row[3], level: 3, parent_id: parent3.id, code: "#{parent3.code}.#{(MClass.where("parent_id=#{parent3.id}").limit(1).order("id DESC").last.code.last.to_i rescue 0)+1}"
          )
          if $M3_save.save
            parent4 = $M3_save
            $M3_save.set_path
          else
            return {error: 1, message: line == 0 ? "#{FlashMessage.recheck_csv}. #{$M3_save.full_messages}" : "#{FlashMessage.partial_import_success(line)}. #{$M3_save.full_messages}"}
          end
        end
      end
      unless row[4].nil?
        unless MClass.find_by_name(row.to_hash["M-Class 4"]).present?
          m4_save = MClass.new(name: row[4], level: 4, parent_id: parent4.id, code: "#{parent4.code}.#{(MClass.where("parent_id=#{parent4.id}").limit(1).order("id DESC").last.code.last.to_i rescue 0)+1}")
          return {error: 1, message: line == 0 ? "#{FlashMessage.recheck_csv}. #{m4_save.full_messages}" : "#{FlashMessage.partial_import_success(line)}. #{m4_save.full_messages}"} unless m4_save.save
          m4_save.set_path
        end
      end
      line += 1
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
