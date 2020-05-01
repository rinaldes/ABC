class Product < ActiveRecord::Base
  belongs_to :brand
  belongs_to :colour2, class_name: 'Colour'
  belongs_to :colour3, class_name: 'Colour'
  belongs_to :colour4, class_name: 'Colour'
  belongs_to :m_class
  belongs_to :unit
  belongs_to :size
  belongs_to :colour
  belongs_to :department, class_name: 'MClass'

  has_many :purchase_request_details
  has_many :selling_prices
  has_many :product_details
  has_many :receivings
  has_many :branch_prices
  has_many :product_sizes
  has_many :product_catalogs
  has_many :catalogs, through: :product_catalogs

  validates_presence_of [:brand_id, :article, :m_class_id, :unit_id, :size_id, :barcode, :colour, :harga_member_eceran]
  #validates_format_of :supplier, :with => /^[a-zA-Z0-9\d\s-.]*$/i, :multiline => true, :message => "hanya mengijinkan input alphabet"
  validates_format_of :purchase_price, :with => /^[0-9\s,.]*$/i, :multiline => true, :message => "masukkan bilangan bulat atau desimal saja"
  validates_uniqueness_of :article, :scope => [:colour_code, :brand_id, :size_id]

# validates :barcode, uniqueness: {message: "MClass, article, brand, and colour already been taken"}

  accepts_nested_attributes_for :product_sizes, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :branch_prices, reject_if: :all_blank, allow_destroy: true

  mount_uploader :image, ImageUploader

  def check_transaction
    return false if ReceivingDetail.where("receiving_details.product_id=?", self.id).joins(product_size: :product).limit(1).present?
    true
  end

  def set_price
    price_after_discount1 = purchase_price*(100-brand.discount_percent1)/100
    price_after_discount2 = price_after_discount1*(100-brand.discount_percent2)/100
    price_after_discount3 = price_after_discount2*(100-brand.discount_percent3)/100
    price_after_discount4 = price_after_discount3*(100-brand.discount_percent4)/100
    h_bandrol = 0
    self.cost_of_products = price_after_discount4
    if brand.set_harga == 'Normal'
      self.margin_rp = price_after_discount4/margin_percent*100# if margin_rp.blank?
      harga_kredit = margin_percent1.to_i == 0 ? 0 : self.margin_rp/margin_percent1*100
      self.harga_kredit = harga_kredit
      h_bandrol = margin_percent4.to_i == 0 ? 0 : harga_kredit/margin_percent4*100
      self.harga_member_eceran = h_bandrol-h_bandrol*margin_percent2/100
      self.harga_eceran = h_bandrol-h_bandrol*margin_percent3/100
    elsif brand.set_harga == 'Pabrik'
      h_bandrol = self.purchase_price+margin_percent4
      harga_kredit = h_bandrol-h_bandrol*margin_percent1/100
      harga_member_eceran = (h_bandrol-h_bandrol*margin_percent2/100).to_i
      harga_eceran = (h_bandrol-h_bandrol*margin_percent3/100).to_i
    elsif brand.set_harga == 'Obral'
      harga_eceran = self.cost_of_products/margin_percent3*100
      harga_member_eceran = (harga_eceran/margin_percent2*100).to_i
      h_bandrol = harga_eceran/margin_percent4*100
      self.harga_kredit = (h_bandrol-h_bandrol*margin_percent1/100).to_i
    end
    self.harga_bandrol = h_bandrol.to_i
    self.selling_price = h_bandrol.to_i
    self.save
  end

  def print_barcode
    hash = {'1' => 'S','2' => 'P','3' => 'R','4' => 'I','5' => 'N','6' => 'G','7' => 'L','8' => 'O','9' => 'V','0' => 'E'}
    modal = cost_of_products.to_i.to_s.chop.chop
    modal_s = []
    article_colour = [article, colour_code].compact.join(' ')
    0.upto(modal.size-1)  do |i|
      modal_s << hash[modal[i].to_s]
    end
    "printTextBarcode('#{barcode}', '#{modal_s.join('')}', '#{article_colour[0..19]}', '#{article_colour[20..article.size-1]}')"
  end

  def full_colour
    colour_code.present? ? [colour_code] : [(colour.name rescue nil), (colour2.name rescue nil), (colour3.name rescue nil), (colour4.name rescue nil)].compact
  end

  #Move to fast or slow or dead
  def self.set_status4
    #Move to fast or slow
    products = SalesDetail.where("sales_details.created_at BETWEEN '#{(Time.now-14.days).strftime('%Y-%m-%d 00:00:00')}' AND '#{(Time.now).strftime('%Y-%m-%d 23:59:59')}'")
      .group("product_id").select("SUM(quantity) AS sum_quantity, product_id").joins(product_size: :product)
    products.each{|product|
      mutation_amount = (ProductDetail.where("product_id=#{product.product_id}").joins(:product_size).map(&:available_qty).compact.sum.to_f+product.sum_quantity.to_f)*100
      Product.find(product.product_id).update_attributes(status4: product.sum_quantity.to_f/mutation_amount < 10 ? 'Fast Moving' : 'Slow Moving')
    }

    #Move to dead
    Product.where("id NOT IN (#{products.map(&:product_id).join(', ')})").update_all("status4='Dead Moving'")
  end

  def colour_list
    [(self.colour.name rescue nil), (self.colour2.name rescue nil), (self.colour3.name rescue nil), (self.colour4.name rescue nil)].compact.join('/')
  end

  def full_product
    product = []
    product << self.product.name if self.product_id.present?
    product << self.product2.name if self.product2_id.present?
    product << self.product3.name if self.product3_id.present?
    product << self.product4.name if self.product4_id.present?
    return product
    # (self.product_id.present? ? self.product.name : "") + (self.product2_id.present? ? self.product2.name : "") + (self.product3_id.present? ? self.product3.name : "") + (self.product4_id.present? ? self.product4.name : "")
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["barcode", "brand", "article", "size", "department", "m_class", "unit", "colour", "colour 2", "colour 3", "colour 4", "colour_code", "purchase_price", "selling_price", "status1", "status2",
        "status3", "status4", "status5", "first_po", "margin_percent1", "margin_percent2", "margin_percent3", "margin_percent4", "margin_percent", "harga_bandrol", "harga_eceran", "harga_member_eceran",
        "harga_kredit", 'supplier_name']
      all.each do |product|
        colour2 = Colour.find(product.colour2_id).name rescue ' '
        colour3 = Colour.find(product.colour3_id).name rescue ' '
        colour4 = Colour.find(product.colour4_id).name rescue ' '
        csv << [product.barcode, (product.brand.name rescue ''), product.article, product.size.description, (product.brand.department.name rescue ''), product.m_class.name, (product.unit.name rescue ''),
          (product.colour.name rescue ''), colour2, colour3, colour4, product.colour_code, product.cost_of_products, product.selling_price, product.status1, product.status2, product.status3, product.status4,
          product.status5, product.first_po, product.margin_percent1, product.margin_percent2, product.margin_percent3, product.margin_percent4, product.margin_percent, product.harga_bandrol,
          product.harga_eceran, product.harga_member_eceran, product.harga_kredit, product.brand.supplier.name]
      end
    end
  end

  def self.to_csv2(options = {})
    CSV.generate(options) do |csv|
      csv << ["barcode", "brand", "article", "size", "department", "m_class", "unit", "colour", "colour 2", "colour 3", "colour 4", "colour_code", "purchase_price", "selling_price", "discount_price",
        "discount_price2", "discount_price3", "percentage_price", "netto", "cost_date", "sell_price_date", "purchase_price_date", "status", "status1", "status2", "status3", "status4", "status5", "first_po",
        "margin_percent1", "margin_percent2", "margin_percent3", "margin_percent4", "margin_percent", "harga_bandrol", "harga_eceran", "harga_member_eceran", "harga_kredit"]
    end
  end

  def self.import_perbaikan_article(file)
    CSV.foreach(file.path, headers: true) do |row|
      Product.find_by_article(row['article'].to_i.to_s).update_attributes(article: row['article']) rescue ''
    end
  end

  def self.import_barcode_size(file)
    CSV.foreach(file.path, headers: true) do |row|
      compare_article = "(TRIM(LOWER(article))=TRIM(LOWER('#{row['article_clean'].gsub("  ", " ").gsub("'", "'\'")}')) OR TRIM(LOWER(article))=TRIM(LOWER('#{row['article'].gsub("  ", " ").gsub("'", "'\'")}')))"
      product_size = (ProductSize.where("LOWER(TRIM(size_number))=LOWER(TRIM('#{row['size']}')) AND TRIM(article)=TRIM('#{row['article_clean'].gsub("  ", " ").gsub("'", "'\'")}') AND LOWER(TRIM(colour_code))=LOWER(TRIM('#{row['warna']}'))").joins(:size_detail, :product).first)

      product_size = (ProductSize.where("LOWER(TRIM(size_number))=LOWER(TRIM('#{row['size']}')) AND #{compare_article} AND LOWER(TRIM(colour_code))=LOWER(TRIM('#{row['warna']}'))").joins(:size_detail, :product).first) if product_size.blank?
#      raise product_size.inspect

      if row['warna'] == '0' || row['warna'].blank?
        product_size = ProductSize.where("LOWER(TRIM(size_number))=LOWER(TRIM('#{row['size']}')) AND TRIM(article)=TRIM('#{row['article_clean'].gsub("  ", " ").gsub("'", "'\'")}')").joins(:product, :size_detail).first rescue nil
        product_size = (ProductSize.where("LOWER(TRIM(size_number))=LOWER(TRIM('#{row['size']}')) AND #{compare_article}").joins(:product, :size_detail).first rescue nil) if product_size.blank?
      end

      if (row['size'].blank? || row['size'] == '0' || row['size'] == 'All Size')
        product_size = ProductSize.where("TRIM(LOWER(article))=TRIM(LOWER('#{row['article_clean'].gsub("  ", " ").gsub("'", "'\'")}')) AND LOWER(TRIM(colour_code))=LOWER(TRIM('#{row['warna']}'))").joins(:product).first rescue nil
      end

      if (row['size'].blank? || row['size'] == '0' || row['size'] == 'All Size') && (row['warna'] == '0' || row['warna'].blank?)
        product_size = ProductSize.where("TRIM(article)=TRIM('#{row['article'].gsub("'", "'\'")}') OR TRIM(article)=TRIM('#{row['article_clean'].gsub("'", "'\'")}')").joins(:product).first rescue nil
        product_size = (ProductSize.where(compare_article).joins(:product).first rescue nil) if product_size.blank?
      end
      product_size.update_attributes(barcode_size: sprintf('%08d', row['barcode'].to_i)) if product_size.present?
    end
    CSV.generate({}) do |csv|
      csv << %w(barcode	article	article_clean warna	size reason)
      CSV.foreach(file.path, headers: true) do |row|
        product_size = ProductSize.find_by_barcode_size(sprintf('%08d', row['barcode'].to_i))
        if product_size.blank?
          c = [row['barcode'], row['article'], row['article_clean'], row['warna'], row['size']]
          if Product.where("LOWER(article)=LOWER('#{row['article'].gsub("'", "''")}') OR LOWER(article)=LOWER('#{row['article_clean'].gsub("'", "''")}')").blank?
            c << "Article Not Found"
          elsif row['warna'] != '0' && Product.where("LOWER(colour_code)=LOWER('#{row['warna']}') AND (LOWER(article)=LOWER('#{row['article']}') OR LOWER(article)=LOWER('#{row['article_clean']}'))").blank?
            c << "Colour Not Found"
          else
            c << "Size Not Found"
          end
          csv << c
        end
      end
    end
  end

  def self.import(file)
    line = 0
csvs = []
    CSV.foreach(file.path, headers: true) do |row|

      parameters = ActionController::Parameters.new(row.to_hash)
      brand = Brand.where("TRIM(brands.name)=TRIM('#{row["brand"].titleize.gsub("'", "''")}') AND suppliers.code='#{row['supplier_code']}'").joins(:supplier).first rescue nil
      supplier = brand.supplier rescue nil
      size = Size.find_by_description(row["size"].titleize).id rescue ''
      unit = Unit.find_by_short_name(row["unit"].titleize).id rescue ''
      department = MClass.find_by_code(row["department"].titleize).id rescue ''
      m_class = row["m_class2"].present? ? (MClass.find_by_code(row["m_class2"]) || MClass.find_by_code("0#{row["m_class2"]}") || MClass.find_by_code("00#{row["m_class2"]}")) : (MClass.find_by_code(row["m_class1"]) || MClass.find_by_code("0#{row["m_class1"]}") || MClass.find_by_code("00#{row["m_class1"]}"))
      colour = Colour.find_by_name(row["colour"].gsub(' ', '').titleize) rescue nil
      unless colour
        begin
          colour = Colour.new code: "C#{('%03d' % ((Colour.last.code.gsub('C', '').to_i rescue 0)+1))}", name: row["colour"].gsub(' ', '').titleize
          colour.save
        rescue
          colour = Colour.first
        end
      end
      colour2 = Colour.find_by_name(row["colour 2"].titleize).id rescue ''
      colour3 = Colour.find_by_name(row["colour 3"].titleize).id rescue ''
      colour4 = Colour.find_by_name(row["colour 4"].titleize).id rescue ''

      purchase_price = row["purchase_price"].gsub(',', '').to_f rescue "0".to_f
      discount1 = 0#brand.discount_percent1.to_f rescue "0".to_f
      discount2 = 0#brand.discount_percent2.to_f rescue "0".to_f
      discount3 = 0#brand.discount_percent3.to_f rescue "0".to_f
      discount4 = 0#brand.discount_percent4.to_f rescue "0".to_f
      set_harga = brand.set_harga.upcase rescue ''
      price_after_discount1 = purchase_price * (100 - discount1) / 100
      price_after_discount2 = price_after_discount1 * (100 - discount2) / 100
      price_after_discount3 = price_after_discount2 * (100 - discount3) / 100
      price_after_discount4 = price_after_discount3 * (100 - discount4) / 100
      margin_percent1 = row["percent_kredit"].to_f rescue "0".to_f
      margin_percent2 = row["percent_member_eceran"].to_f rescue "0".to_f
      margin_percent3 = row["percent_eceran"].to_f rescue "0".to_f
      margin_percent4 = row["percent_bandrol"].to_f rescue "0".to_f
      margin_percent = row["margin_percent"].to_f rescue "0".to_f
      harga_bandrol = 0
      mod = price_after_discount4 % 500
      cost_of_products = price_after_discount4

      if set_harga == 'NORMAL'
        margin_rp = price_after_discount4 / margin_percent * 100
        harga_kredit = margin_rp / (margin_percent1 == 0.0 ? 100 : margin_percent1) * 100
        harga_kredit_mod = harga_kredit % 500

        kredit = harga_kredit_mod > 250 ? harga_kredit+500-harga_kredit_mod : harga_kredit-harga_kredit_mod
        harga_bandrol = (harga_kredit/(margin_percent4 <= 0.0 ? 100 : margin_percent4)*100).to_i rescue harga_kredit
        harga_bandrol_mod = harga_bandrol % 500

        bandrol = harga_bandrol_mod > 250 ? harga_bandrol+500-harga_bandrol_mod : harga_bandrol-harga_bandrol_mod
        harga_eceran = (harga_bandrol-harga_bandrol*margin_percent3/100).to_i rescue harga_bandrol
        harga_eceran_mod = harga_eceran % 500
        eceran = harga_eceran_mod > 250 ? harga_eceran+500-harga_eceran_mod : harga_eceran-harga_eceran_mod

        harga_member_eceran = (harga_bandrol-harga_bandrol*margin_percent2/100).to_i rescue harga_bandrol
        harga_member_eceran_mod = harga_member_eceran % 500
        member_eceran = harga_member_eceran_mod > 250 ? harga_member_eceran+500-harga_member_eceran_mod : harga_member_eceran-harga_member_eceran_mod
      elsif set_harga == 'PABRIK'
        margin_rp == ''
        margin_percent == ''

        harga_bandrol = purchase_price+margin_percent4
        harga_bandrol_mod = harga_bandrol % 500
        bandrol = harga_bandrol_mod > 250 ? harga_bandrol+500-harga_bandrol_mod : harga_bandrol-harga_bandrol_mod

        harga_kredit = bandrol-bandrol*margin_percent1/100
        harga_kredit_mod = harga_kredit % 500
        kredit = harga_kredit_mod > 250 ? harga_kredit+500-harga_kredit_mod : harga_kredit-harga_kredit_mod

        harga_member_eceran = (bandrol-bandrol*margin_percent2/100).to_i
        harga_member_eceran_mod = harga_member_eceran % 500
        member_eceran = harga_member_eceran_mod > 250 ? harga_member_eceran+500-harga_kredit_mod : harga_member_eceran-harga_member_eceran_mod

        harga_eceran = (bandrol-bandrol*margin_percent3/100).to_i
        harga_eceran_mod = harga_eceran % 500
        eceran = harga_eceran_mod > 250 ? harga_eceran+500-harga_eceran_mod : harga_eceran-harga_eceran_mod

      elsif set_harga == 'OBRAL'
        harga_eceran = cost_of_products/(margin_percent3 == 0.0 ? 100 : margin_percent3)*100
        harga_eceran_mod = harga_eceran % 500
        eceran = harga_eceran_mod > 250 ? harga_eceran+500-harga_eceran_mod : harga_eceran-harga_eceran_mod

        harga_member_eceran = (harga_eceran/(margin_percent2 == 0.0 ? 100 : margin_percent2)*100).to_i
        harga_member_eceran_mod = harga_member_eceran % 500
        member_eceran = harga_member_eceran_mod > 250 ? harga_member_eceran+500-harga_member_eceran_mod : harga_member_eceran-harga_member_eceran_mod

        harga_bandrol = harga_eceran/(margin_percent4 == 0.0 ? 100 : margin_percent4)*100
        harga_bandrol_mod = harga_bandrol % 500
        bandrol = harga_bandrol_mod > 250 ? harga_bandrol+500-harga_bandrol_mod : harga_bandrol-harga_bandrol_mod

        harga_kredit = (bandrol-bandrol*margin_percent1/100).to_i
        harga_kredit_mod = harga_kredit % 500
        kredit = harga_kredit_mod > 250 ? harga_kredit+500-harga_kredit_mod : harga_kredit-harga_kredit_mod

        selling_price = harga_bandrol.to_i
      elsif set_harga == 'MANUAL'
        harga_bandrol = row["harga_bandrol"].gsub(',', '')
        harga_kredit = row["harga_kredit"].gsub(',', '')
        harga_member_eceran = row["harga_member_eceran"].gsub(',', '') rescue nil
        harga_eceran = row["harga_eceran"].gsub(',', '')
      end
      harga_bandrol = row["harga_bandrol"].gsub(',', '')
      harga_kredit = row["harga_kredit"].gsub(',', '')
      harga_member_eceran = row["harga_member_eceran"].gsub(',', '') rescue nil
      harga_eceran = row["harga_eceran"].gsub(',', '')
      if Product.joins(brand: :supplier).where("supplier_id=#{(brand.supplier_id rescue 0)}").order("id ASC").present?
        code = sprintf '%04d', (Product.joins(brand: :supplier).where("supplier_id=#{(brand.supplier_id rescue 0)}").order("id ASC").last.code.to_i)+1 rescue 1
      else
        code = sprintf '%04d', 1
      end
      product = new(parameters.permit(
        :article, :status1, :status2, :status3, :status4, :status5, :margin_percent, :margin_rp, :colour_code, :status5
      ).merge(code: code, brand_id: (brand.id rescue nil), size_id: size, unit_id: unit, colour_id: colour.id, colour2_id: colour2, colour3_id: colour3, colour4_id: colour4,
        m_class_id: (m_class.id rescue nil), department_id: department, harga_bandrol: harga_bandrol, harga_kredit: harga_kredit, harga_member_eceran: harga_member_eceran, harga_eceran: harga_eceran,
        margin_rp: margin_rp, cost_of_products: cost_of_products, selling_price: harga_bandrol, margin_percent1: row["percent_kredit"], margin_percent2: row["percent_member_eceran"],
        margin_percent3: row["percent_eceran"], margin_percent4: row["percent_bandrol"],
        barcode: [(brand.supplier.code.gsub('S', '') rescue ''), (m_class.parent(1).code.reverse[0..1].reverse rescue ''), (m_class.parent(2).code[0..5] rescue ''), code].compact.join(''),
        purchase_price: purchase_price)
      )
      if product.save
        product.size.size_details.each{|sd|
          product_size = ProductSize.where(size_detail_id: sd.id, product_id: product.id).first
          ProductSize.create size_detail_id: sd.id, product_id: product.id, default_min_stock: 0 if product_size.blank?
        }
      elsif Product.find_by_article(row['article']).blank?
         one_row = {}
         ['supplier_code','brand','article','size','department','m_class','m_class1','m_class2','unit','colour','colour 2','colour 3','colour 4','colour_code','purchase_price','selling_price','status1','status2','status3','status4','status5','first_po','percent_bandrol','percent_eceran','percent_member_eceran','percent_kredit','margin_percent','harga_bandrol','harga_eceran','harga_member_eceran','harga_kredit','min_stock'].each{|a|
           one_row = one_row.merge({a => row[a]})
         }
         csvs << one_row.merge('reason' => product.errors.full_messages.join(','))
#        return {error: 1, message: line == 0 ? "Import failed, please recheck CSV file. #{product.errors.full_messages.join('<br/>')}" : "Successfully imported until line #{line}. Failed imported  from line #{line+1}. Please recheck and reupload from line #{line+1}. #{product.errors.full_messages.join('<br/>')}"}
      end
      line += 1
    end
#    return {error: 0, message: "Successfully imported"}
    CSV.generate({}) do |csv|
      csv << ['supplier_code','brand','article','size','department','m_class','m_class1','m_class2','unit','colour','colour 2','colour 3','colour 4','colour_code','purchase_price','selling_price','status1','status2','status3','status4','status5','first_po','percent_bandrol','percent_eceran','percent_member_eceran','percent_kredit','margin_percent','harga_bandrol','harga_eceran','harga_member_eceran','harga_kredit','min_stock', 'reason']
      csvs.each do |row|
#raise row['supplier_code'].inspect
        brand = Brand.where("TRIM(brands.name)=TRIM('#{row["brand"].titleize.gsub("'", "''")}') AND suppliers.code='#{row['supplier_code']}'").joins(:supplier).first rescue nil
 #       if brand.present? && Product.find_by_brand_id_and_article_and_colour_code(brand.id, row['article'], row['colour_code']).blank?
          one_row = []
          ['supplier_code','brand','article','size','department','m_class','m_class1','m_class2','unit','colour','colour 2','colour 3','colour 4','colour_code','purchase_price','selling_price','status1','status2','status3','status4','status5','first_po','percent_bandrol','percent_eceran','percent_member_eceran','percent_kredit','margin_percent','harga_bandrol','harga_eceran','harga_member_eceran','harga_kredit','min_stock', 'reason'].each{|a|
            one_row << row[a]
          }
#raise one_row.inspect
          csv << one_row
        #end
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

  def count_qty(qty=nil, size_detail=nil)
    0
  end

  def count_total_qty(qty=nil)
    0
  end

end
