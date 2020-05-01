class Sale < ActiveRecord::Base
  # ihsan.husnul@kiranatama.com
  attr_accessor :sale_details

  belongs_to :store, :class_name => 'Branch', :foreign_key => 'store_id'
  belongs_to :member
  belongs_to :user

  has_many :sales_details
  accepts_nested_attributes_for :sales_details
  attr_reader :sales_details_attributes

  after_create :connect_to_finance
  after_create :set_point_and_level_member

  def set_point_and_level_member
    #Set Point
    return if member.blank?
    member_level = member.member_level
    new_accumulated_price = member.accumulated_price.to_f+total_price.to_f
    if member_level && member_level.minimum_amount.to_f <= total_price.to_f
      additional_point = member_level.set_point
      total_point = additional_point*total_price
      new_point = member.point+total_point
      member.point_histories.create additional_point: total_point, old_point: member.point, new_point: new_point, total_current_price: total_price, total_accumulated_price: new_accumulated_price
      member.update_attributes(point: new_point, accumulated_price: new_accumulated_price)
    end

    #naik level
    if member_level.present?
      new_level = MemberLevel.where("minimum_amount>#{member_level.minimum_amount} AND minimum_amount<=#{new_accumulated_price}").order("minimum_amount DESC").first
      if new_level.present?
        member.update_attributes(member_level_id: new_level.id)
        #cashback
        cashback = Cashback.where("member_level_id=#{new_level.id} AND transaction_amount<#{total_price}").order("transaction_amount DESC").first
        CashbackMember.create member_id: member_id, transaction_amount: total_price, cashback_amount: cashback.cashback_amount, member_level_id: new_level.id, cashback_id: cashback.id if cashback.present?
      end
    else
      member.update_attributes(member_level_id: 1)
    end
  end

  def connect_to_finance #tobe discussed with rjp
    if voucher_code.present?
      voucher = ArVoucherDetail.find_by_code(voucher_code)
      ar_number = "AR/" + Time.now.strftime("%m/") + Time.now.strftime("%y-") + sprintf('%06d', AccountReceivable.where("extract(year from created_at) = ? and extract(month from created_at) = ?", Time.now.strftime("%Y"), Time.now.strftime("%m")).count + 1)
      ar = AccountReceivable.new ar_number: ar_number, transaction_number: bill_number, member_id: member_id, total_amount: total_outstanding, outstanding: total_outstanding, bill_to_name: member.name,
        bill_to_email: member.email, bill_to_phone: member.phone_number, bill_to_address: member.address, branch_id: user.branch_id
      if ar.save
        voucher.ar_voucher.ar_voucher_payment_schedules.each{|vd|
          Payment.create amount: vd.amount, due_date: "#{Time.now+vd.due_date_number.month.strftime("%Y-%m-#{vd.due_date}")}", payment_amount: vd.amount, account_receivable_id: ar.id,
            payment_number: vd.payment_number
        }
      end
    end
  end

  scope :all_sales, lambda{|conditions|{
    conditions: [conditions.join(' AND ')]
  }}

  scope :sales_report, lambda{|conditions|{
    conditions: [conditions.join(' AND ')], joins: [sales_details: [goods_size: [goods: [:type, brand: [:supplier]]]], store: [:branch]],
    select: "sales.*, SUM(sales_details.quantity) AS total_qty, SUM(sales_details.price * sales_details.quantity) AS bruto,
      SUM(sales_details.price_after_discount * sales_details.quantity) AS netto", group: "sales.id"
  }}

  scope :sales_day_by_day, lambda{|conditions|{
    conditions: [conditions.push("MONTH(sales.created_at)=MONTH(NOW())").join(' AND ')], group: "sales.id",
    joins: [sales_details: [goods_size: [goods: [:type, brand: [:supplier]]]], store: [:branch]],
    select: "sales.*, SUM(sales_details.quantity) AS total_qty, SUM(sales_details.price * sales_details.quantity) AS bruto,
      SUM(sales_details.price_after_discount * sales_details.quantity) AS netto"
  }}

  scope :today_sales, lambda{|conditions|{
    conditions: [(conditions+["DATE(sales.created_at)=CURDATE()"]).join(' AND ')], joins: [:sales_details, store: [:branch]],
    select: "sales.*, SUM(sales_details.quantity) AS total_qty, SUM(sales_details.price * sales_details.quantity) AS bruto,
      SUM(sales_details.price_after_discount * sales_details.quantity) AS netto"
  }}

  def self.pos_data params
    conditions = []
    if params[:branch].present?
      branch = Branch.find_by_name(params[:branch])
      conditions << "store_id in (select id from stores where branch_id=#{branch.id})"
    end
    conditions << "created_at <= '#{params[:start_date]}'" if params[:start_date].present?
    conditions << "updated_at <= '#{params[:end_date]} 23:59:59'" if params[:end_date].present?
    sales = Sale.all_sales conditions
    sales.group_by{|sale|(sale.store.branch rescue nil)}.map{|sale|
      {store_name: (sale[0].name rescue ''), total_price: sale[1].map(&:total_price).compact.sum}
    }
  end

  def self.create_from_pos(data)
    the_data = JSON.parse(data)
    the_data["sales_order"].each do |sales_data|
      puts "==============="
      puts sales_data
      puts "==============="
      sale = Sale.new
      # {"id"=>1, "transactionNumber"=>"00001", "transactionDate"=>"2015-06-24 13:28:09", "createdAt"=>"2015-06-24 13:28:09", "memberId"=>1, "gross"=>300000.0, "nett"=>260000.0, "cashierId"=>1, "branchId"=>1, "payCash"=>300000.0, "payDebit"=>0.0, "payCredit"=>0.0, "payVoucher"=>0.0, "debitNumber"=>nil, "creditNumber"=>nil, "voucherNumber"=>nil, "debitBankId"=>0, "creditBankId"=>0, "salesOrderDetails"=>[{"id"=>1, "salesOrderId"=>1, "goodsDetailId"=>53, "quantity"=>1, "price"=>150000.0, "discPercent"=>0.0, "discNominal"=>0.0}, {"id"=>2, "salesOrderId"=>1, "goodsDetailId"=>136, "quantity"=>1, "price"=>110000.0, "discPercent"=>0.0, "discNominal"=>0.0}]}

      # sale.payment_type = sales_data["paymentType"]
      sale.transaction_date = sales_data["transactionDate"]
      # sale.sales_bill_id = sales_data["salesBillId"]
      sale.member_id = sales_data["memberId"]
      sale.client_id = sales_data["cashierId"]
      sale.store_id = sales_data["branchId"]
      sale.total_price = sales_data["nett"]
      # sale.total_discount = sales_data["totalDiscount"]
      sale.created_at = sales_data["createdAt"]
      sale.code = sales_data["transactionNumber"]
      sale.user_id = sales_data["cashierId"]
      sale.bill_number = sales_data["transactionNumber"]
      
      temp_detail = []
      sales_data["salesOrderDetails"].each do |detail|
        the_details = {}
        the_details["goods_detail_id"] = detail["goodsDetailId"]
        the_details["quantity"] = detail["quantity"]
        the_details["price"] = detail["price"]
        #the_details["price_after_discount"] = detail["priceAfterDiscount"]
        #the_details["sale_id"] = detail["saleId"]
        the_details["discount"] = detail["discPercent"]
        #the_details["discount_type"] = detail["discountType"]
        #the_details["spg_user_name"] = detail["spgUserName"]
        #the_details["spg_bill_number"] = detail["spgBillNumber"]
        temp_detail << the_details
      end
      sale.sales_details_attributes = temp_detail
      sale.save
    end
  end

  def self.by_day_and_branch(date, branch_id)
    unless date.class.eql?(Date)
      date = date.blank? ? Time.now.to_date : (date["year"] + "-" + date["month"] + "-" + date["day"]).to_date
    end
    sales = Sale.where("date(transaction_date) = ?", date)

    if branch_id.present?
      sales = sales.where(:store_id => branch_id)
    end

    return sales
  end

  def self.get_variable_income(sales)
    payment_cash = sales.sum(:payment_cash)
    btp_income_cash = 0
    dp_buying_in = 0
    charge_merchant = 0
    service = 0
    catalogue_book = 0
    total = payment_cash + btp_income_cash + dp_buying_in + charge_merchant + service + catalogue_book
    dp_buying_out = 0
    income_cash = total - dp_buying_out
    omzet_koperasi = 0
    credit_card = sales.sum(:credit_amt)
    debit_card = sales.sum(:debit_amt)
    voucher_amt = sales.sum(:voucher_amt)
    income_non_cash = omzet_koperasi + credit_card + debit_card + voucher_amt
    hash_income = { "payment_cash" => payment_cash, "btp_income_cash" => btp_income_cash, "dp_buying_in" => dp_buying_in, "charge_merchant" => charge_merchant, "service" => service, "catalogue_book" => catalogue_book, "total" => total, "dp_buying_out" => dp_buying_out, "income_cash" => income_cash, "omzet_koperasi" => omzet_koperasi, "credit_card" => credit_card, "debit_card" => debit_card, "voucher_amt" => voucher_amt, "income_non_cash" => income_non_cash }
  end

  def self.get_variable_net_sales(list_income)
    total_income = list_income["total"] + list_income["income_non_cash"]
    btp_out = 0
    bon = 0
    another_income = list_income["btp_income_cash"] + list_income["dp_buying_in"] + list_income["charge_merchant"] + list_income["service"] + list_income["catalogue_book"]
    net_sales = (total_income + btp_out + bon) - another_income
    hash_net_sales = { "total_income" => total_income, "btp_out" => btp_out, "bon" => bon, "another_income" => another_income, "net_sales" => net_sales }
  end

  def self.get_total_price_by_branch_id_and_date(branch_id, date)
    Sale.by_day_and_branch(date, branch_id).sum(:total_price)
  end

  def self.get_total_price_per_month(branch_id, dates)
    Sale.where("store_id = ? AND DATE(transaction_date) between ? AND ?", branch_id, dates.first, dates.last).sum(:total_price)
  end
end
