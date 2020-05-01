class EdcMachine < ActiveRecord::Base
  belongs_to :office, foreign_key: :store_id

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["bank_name", "branch", "edc_serial_number", "account_number", "owner"]
      all.each do |edc_machine|
        csv << [edc_machine.bank_name, edc_machine.branch, edc_machine.edc_serial_number, edc_machine.account_number, edc_machine.owner]
      end
    end
  end

  def self.to_csv2(options = {})
    CSV.generate(options) do |csv|
      csv << ["bank_name", "branch", "edc_serial_number", "account_number", "owner"]
      all.each do |edc_machine|
      end
    end
  end
  
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
   
    if EdcMachine.find_by_bank_name(row["bank_name"].upcase).nil?
      edc_machine = find_by_bank_name(row["bank_name"]) || new
      parameters = ActionController::Parameters.new(row.to_hash)
      edc_machine.update(parameters.permit(:bank_name, :branch, :edc_serial_number, :account_number, :owner))
      edc_machine.save!
    else
      return "Successfully imported until line #{line}. Failed imported  from line #{line+1}. Must unique"
      end
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
  validates :bank_name, :presence => true, :uniqueness => true
  validates :store_id, :presence => true
  validates_format_of :bank_name, :with => /^[a-zA-Z\d\s]*$/i, :multiline => true, :message => "hanya mengijinkan input alphabet"
  validates :branch, :presence => true
  validates_format_of :branch, :with => /^[a-zA-Z\d\s]*$/i, :multiline => true, :message => "hanya mengijinkan input alphabet"
  validates :edc_serial_number, :presence => true
  validates :account_number,:presence =>true, :uniqueness => true
  validates :owner, :presence =>true
  validates_format_of :owner, :with => /^[a-zA-Z\d\s]*$/i, :multiline => true, :message => "hanya mengijinkan input alphabet"
end
