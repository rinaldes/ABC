class SellingPrice < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  belongs_to :receiving
  belongs_to :office
  belongs_to :supplier

  has_many :brands
  has_many :selling_price_details, :dependent => :destroy
  accepts_nested_attributes_for :selling_price_details, :allow_destroy => true

  validates :product_id, presence: true
  #validates :office_id, presence: true
  #validate :hpp_selling_price
  #validates :start_date, presence: true
  #validates :end_date, presence: true
  #validates :hpp, presence: true
  #validates :hpp_average, presence: true

  def hpp_selling_price
    errors.add(:selling_price, "should be greater than hpp or not empty") if selling_price == nil || selling_price.present? && hpp.to_f > selling_price.to_f && selling_price!=0
  end

  def self.number(params)
    number = (SellingPrice.first(:conditions => "code like '#{params[:first_char]}%'", :order => "id DESC").code[1..-1].to_i rescue 0)+1
    return number
  end

  def self.create_number(params)
    init = params[:SellingPrice][:start_date][0]
    number = (SellingPrice.first(:conditions => "start_date like '#{init}%'", :order => "id DESC").code[1..-1].to_i rescue 0)+1
    return number
  end

  def self.get_selling_price_id(selling_price)
    id = (SellingPrice.first(:conditions => "code = '#{selling_price}'", :order => "id DESC").id.to_i rescue 0)
    return id
  end

  def check_transaction
    return false if Product.find_by_selling_price(self.selling_price)
    true
  end

  def margin_amount
    (product.is_bkp? ? selling_price.to_f*0.9 : selling_price).to_f-hpp_average.to_f
  end

  def margin_percent
    margin_amount.to_f/(hpp_2 || product.is_bkp? ? selling_price/1.1 : selling_price).to_f*100 rescue 0
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["supplier_code", "article", "colour_code", "start_date", "end_date", "purchase_price", "selling_price", "percent_bandrol", "percent_eceran", "percent_member_eceran", "percent_kredit", "margin_percent", "harga_bandrol", "harga_eceran", "harga_member_eceran", "harga_kredit"]
      all.each do |selling_price|
        csv << [selling_price.supplier.code, selling_price.product.article, selling_price.product.colour_code, selling_price.start_date, selling_price.end_date]
      end
    end
  end

  def self.to_csv2(options = {})
    CSV.generate(options) do |csv|
      csv << ["supplier_code", "article", "colour_code", "start_date", "end_date", "purchase_price", "selling_price", "percent_bandrol", "percent_eceran", "percent_member_eceran", "percent_kredit", "margin_percent", "harga_bandrol", "harga_eceran", "harga_member_eceran", "harga_kredit"]
    end
  end

  def self.import(file)
    line = 0
    CSV.foreach(file.path, headers: true) do |row|
      parameters = ActionController::Parameters.new(row.to_hash)
      if row["old_article"].present?
        if row["colour_code"].present?
          product = Product.find_by_article_and_colour_code(parameters['old_article'], parameters['colour_code'])
        else
          product = Product.find_by_article(parameters['old_article'])
        end
      end

      if Supplier.exists?(code: row['supplier_code'])
        supp_id = Supplier.find_by_code(row['supplier_code']).id
      else
        return {error: 1, message: "Impor gagal, silakan periksa kembali kode supplier anda."}
      end

      parameters['start_date'] = Time.now() if parameters['start_date'].blank?
      parameters['end_date'] = Time.now() + 2.year if parameters['end_date'].blank?

      begin
        ActiveRecord::Base.transaction do
          selling_price = new(parameters.permit(:start_date, :end_date, :margin, :margin_percent).merge(code: "C#{('%03d' % ((SellingPrice.last.code.gsub('C', '').to_i rescue 0)+1))}", product_id: product.id,
            start_date: parameters['start_date'], end_date: parameters['end_date'], is_active: true, supplier_id: supp_id, selling_price: parameters['selling_price']))
          if selling_price.save
            prod = Product.find(selling_price.product_id)
            prod.update_attributes(selling_price: parameters['selling_price'], purchase_price: parameters['purchase_price'], harga_kredit: parameters['harga_kredit'], harga_eceran: parameters['harga_eceran'],
              harga_bandrol: parameters['harga_bandrol'], harga_member_eceran: parameters['harga_member_eceran'], margin_percent1: parameters["percent_kredit"], article: parameters["new_article"],
              margin_percent2: parameters["percent_member_eceran"], margin_percent3: parameters["percent_eceran"], margin_percent4: parameters["percent_bandrol"], margin_percent: parameters["margin_percent"]
            )
          else
            error_msg = selling_price.errors.full_messages.join('<br/>')
            return {
              error: 1,
              message: line == 0 ? "Import failed, please recheck CSV file. #{error_msg}" : "Successfully imported until line #{line}. Failed imported  from line #{line+1}. Please recheck and reupload from line #{line+1}. #{error_msg}"
            }
          end
        end
      rescue => e
        ActiveRecord::Rollback
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