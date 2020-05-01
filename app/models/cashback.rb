class Cashback < ActiveRecord::Base
	belongs_to :member_level
	validates :transaction_amount, :presence => {message: 'harus diisi'}
	validates :cashback_amount, :presence => {message: 'harus diisi'}
	validates :member_level_id, :presence => {message: 'harus diisi'}

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["transaction_amount", "cashback_amount", "member_level"]
      all.each do |cashback|
        csv << [cashback.transaction_amount, cashback.cashback_amount, cashback.member_level.level]
      end
    end
  end

  def self.to_csv2(options = {})
    CSV.generate(options) do |csv|
      csv << ["transaction_amount", "cashback_amount", "member_level"]
      all.each do |cashback|
      end
    end
  end

  def self.import(file)
    line = 0
    CSV.foreach(file.path, headers: true) do |row|
      parameters = ActionController::Parameters.new(row.to_hash)
      level = MemberLevel.find_by_level(parameters["member_level"]).id rescue 1
      cashback = new(parameters.permit(:transaction_amount, :cashback_amount).merge(member_level_id: level))
      unless cashback.save
        return {error: 1, message: line == 0 ? "Import failed, please recheck CSV file. #{cashback.errors.full_messages.join('<br/>')}" : "Successfully imported until line #{line}. Failed imported  from line #{line+1}. Please recheck and reupload from line #{line+1}. #{cashback.errors.full_messages.join('<br/>')}"}
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