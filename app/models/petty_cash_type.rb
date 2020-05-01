class PettyCashType < ActiveRecord::Base
  before_validation :upcase_save

  validates :name, :presence => {message: 'required'} , :uniqueness => true
  validates_format_of :name, :with => /^[a-zA-Z\d\s]*$/i, :multiline => true, :message => "only input alphabet"

  scope :search, lambda {|search|{
    :order => "code ASC",
    :conditions => [
      'code LIKE ? OR name LIKE ?',
      "%#{search.first}%", "%#{search.first}%"
    ]
  }}

  def upcase_save
    self.name = name.titleize rescue nil
  end

  def self.number(params)
    number = (PettyCashType.first(:conditions => "name like '#{params[:first_char]}%'", :order => "id DESC").code[1..-1].to_i rescue 0)+1
    return number
  end

  def self.create_number(params)
    init = params[:petty_cash_type][:name][0]
    number = (PettyCashType.first(:conditions => "name like '#{init}%'", :order => "id DESC").code[1..-1].to_i rescue 0)+1
    return number
  end

  def self.get_petty_cash_type_id(petty_cash_type)
    id = (PettyCashType.first(:conditions => "code = '#{petty_cash_type}' or name = '#{petty_cash_type}'", :order => "id DESC").id.to_i rescue 0)
    return id
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["code", "name"]
      all.each do |petty_cash_type|
        csv << [petty_cash_type.code, petty_cash_type.name]
      end
    end
  end

  def self.to_csv2(options = {})
    CSV.generate(options) do |csv|
      csv << ["name"]
      all.each do |petty_cash_type|
      end
    end
  end

  def self.import(file)
    line = 0
    CSV.foreach(file.path, headers: true) do |row|
      if find_by_name(row["name"].upcase).nil?
        parameters = ActionController::Parameters.new(row.to_hash)
        petty_cash_type = new(parameters.permit(:name).merge(:code => "PCT#{('%03d' % ((PettyCashType.last.code.gsub('PCT', '').to_i rescue 0)+1))}"))
        unless petty_cash_type.save
          return {error: 1, message: line == 0 ? "Import failed, please recheck CSV file. #{petty_cash_type.errors.full_messages.join('<br/>')}" : "Successfully imported until line #{line}. Failed imported  from line #{line+1}. Please recheck and reupload from line #{line+1}. #{petty_cash_type.errors.full_messages.join('<br/>')}"}
        end
        line += 1
      else
        return {error: 0, message: "Successfully imported"}
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