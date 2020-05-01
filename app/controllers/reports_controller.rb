class ReportsController < ApplicationController
  def eod
  end

  def cashier
    conditions = []
    conditions2 = []
    conditions << "office_id=#{current_user.branch_id}" if current_user.branch_id.present?
    params[:search].each{|param|
      if param[0] == "COUNT(sales)"
        conditions2 << "CAST(#{param[0]} as text) LIKE '%#{param[1]}%'" if param[1].present?
      else
        if param[0] == "to_char(start_amount, '99999999D99')" || param[0] == "to_char(credit, '99999999D99')" || param[0] == "to_char(debit, '99999999D99')"
          parampa = param[1].split(",").join("")
          param[1] = parampa
        end
        conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
      end
    } if params[:search].present?
    @cashiers = SodEod.joins(:user)
      .select("sod_eods.user_id, sod_eods.created_at as ss_created_at, session, machine_id, start_amount, debit, credit, to_char(sod_eods.created_at, 'DD-MM-YYYY') as s_created_at, to_char(start_time, 'HH24:MI') as start_time, to_char(end_time, 'HH24:MI') as end_time, concat(first_name, ' ', last_name) AS username, sod_eods.receipt_count, cash")
      .where(conditions.join(' AND ')).order(default_order('sod_eods')).paginate(page: params[:page], :per_page => PER_PAGE)
    respond_to do |format|
      format.html
      format.js
      format.xls
    end
  end

  def sale
    conditions = ["quantity>0 AND to_char(sales_details.created_at, 'YYYY-MM-DD')=to_char(sales.created_at, 'YYYY-MM-DD')"]
    conditions << "offices.code='#{params[:store_code]}'" if params[:store_code].present?
    conditions << "to_char(transaction_date, 'YYYY-MM-DD')='#{params[:transaction_date]}'" if params[:transaction_date].present?
    conditions << "transaction_date>='#{params[:start_date]} 00:00:00'" if params[:start_date].present?
    conditions << "transaction_date<='#{params[:end_date]} 23:59:59'" if params[:end_date].present?
    conditions << "member_id=#{params[:member_id]}" if params[:member_id].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    if params[:all_stores] == 'Store'
      @sales = Sale.select("offices.code AS kode_toko, office_name, SUM(sales_details.total_price) AS total_price, SUM(sales_details.quantity) AS total_quantity, SUM(ppn) AS total_ppn,
        SUM(capital_price*quantity) AS capital_price").joins(:store, :sales_details).group("offices.code, office_name").where(conditions.join(' AND ')).order("total_price DESC")
    elsif params[:all_stores] == 'Item'
      @sales = SalesDetail.select("article, products.description, SUM(sales_details.total_price) AS total_price, SUM(ppn) AS ppn, SUM(capital_price*quantity) AS capital_price,
        SUM(quantity) AS quantity").joins(:product, sale: :store).group("article, products.description").where(conditions.join(' AND ')).order("total_price DESC")
    elsif params[:all_stores] == 'Category'
      conditions << "LOWER(name) LIKE LOWER('%#{params[:m_class_name]}%')" if params[:m_class_name].present?
      @sales = SalesDetail.select("m_class_id, SUM(sales_details.total_price) AS total_price, SUM(ppn) AS ppn, SUM(capital_price*quantity) AS capital_price,
        SUM(quantity) AS quantity").joins(:product, sale: :store).group("m_class_id").where(conditions.join(' AND ')).order("total_price DESC")
    elsif params[:all_stores] == 'Member'
      @sales = SalesDetail
        .select("member_id, members.name AS member_name, SUM(sales_details.total_price) AS total_price, SUM(ppn) AS ppn, SUM(capital_price*quantity) AS capital_price, SUM(quantity) AS quantity")
        .joins(:product, sale: [:store, :member]).group("member_id, members.name").where(conditions.join(' AND ')).order("total_price DESC").paginate(:page => params[:page], :per_page => 10) || []
    elsif params[:all_stores] == 'Date'
      @sales = Sale.select("to_char(transaction_date, 'YYYY-MM-DD') AS transaction_date, SUM(quantity) AS total_quantity, SUM(sales_details.total_price) AS total_price, SUM(ppn) AS total_ppn,
        SUM(capital_price*quantity) AS capital_price").joins(:store, :sales_details).group("to_char(transaction_date, 'YYYY-MM-DD')").where(conditions.join(' AND '))
        .order("to_char(transaction_date, 'YYYY-MM-DD') ASC")
      @sales_per_item = SalesDetail.select("article, products.description, SUM(sales_details.total_price) AS total_price, SUM(ppn) AS ppn, SUM(capital_price*quantity) AS capital_price,
        SUM(quantity) AS quantity").joins(:product, sale: :store).group("article, products.description").where(conditions.join(' AND ')).order("products.description ASC")
    elsif params[:all_stores] == 'Hour'
      @sales = Sale.select("to_char(transaction_date, 'YYYY-MM-DD') AS transaction_date, SUM(quantity) AS total_quantity, SUM(sales_details.total_price) AS total_price, SUM(ppn) AS total_ppn,
        SUM(capital_price*quantity) AS capital_price").joins(:store, :sales_details).group("to_char(transaction_date, 'YYYY-MM-DD')").where(conditions.join(' AND '))
        .order("to_char(transaction_date, 'YYYY-MM-DD') ASC")
      @sales_per_hour = Sale.select("to_char(transaction_date, 'HH24 YYYY-MM-DD') AS transaction_date, SUM(quantity) AS total_quantity, SUM(sales_details.total_price) AS total_price, SUM(ppn) AS total_ppn,
        SUM(capital_price*quantity) AS capital_price").joins(:store, :sales_details).group("to_char(transaction_date, 'HH24 YYYY-MM-DD')").where(conditions.join(' AND '))
        .order("to_char(transaction_date, 'HH24 YYYY-MM-DD') ASC")
      @sales_per_item = SalesDetail.select("article, products.description, SUM(sales_details.total_price) AS total_price, SUM(ppn) AS ppn, SUM(capital_price*quantity) AS capital_price,
        SUM(quantity) AS quantity").joins(:product, sale: :store).group("article, products.description").where(conditions.join(' AND ')).order("products.description ASC")

    elsif params[:all_stores] == 'Month'
      @condition = conditions
      @month = params[:months]
      month_report
    end
    tgl_xls = ""
    tgl_xls << "_FROM_" + params[:start_date] if params[:start_date].present?
    tgl_xls << "_UNTIL_" + params[:end_date] if params[:end_date].present?
    respond_to do |format|
      format.html
      format.js
      format.xls { send_data sale_xls, :filename => "REPORT_SALE_#{Office.where(:code => params[:store_code]).first.office_name rescue "ALL"}" + tgl_xls +".xls", :type =>  "application/vnd.ms-excel" }
    end
  end

  def monthly_stock
    if params[:all_stores].present?
      conditions = []
      if params[:all_stores] == 'Store'
        stock_group_by_store_per_month
      elsif params[:all_stores] == 'Item'
        stock_group_by_item_per_month
        @first_sale = Sale.where("to_char(transaction_date, 'YYYY-MM')='#{params[:year]}-#{sprintf('%02d', Date::MONTHNAMES.index(params[:month]))}'").limit(1).first
      end

      respond_to do |format|
        format.html
        format.xls { send_data stock_xls, :filename => "REPORT_STOCK_#{Office.where(:code => params[:store_code]).first.office_name rescue "ALL"}.xls", :type =>  "application/vnd.ms-excel" }
        format.js
      end
    else
      flash[:error] = "Please Choose Group By" if params[:format] == 'xls'
      respond_to do |format|
        format.html
        format.xls {redirect_to '/reports/stock'}
      end
    end
  end

  def store_stock_movement
    return @product_mutation_histories = [] if params[:branch_id].blank?
    now = Time.now
    conditions = ["EXTRACT(MONTH FROM product_mutation_histories.created_at)=#{now.strftime('%m')} AND EXTRACT(YEAR FROM product_mutation_histories.created_at)=#{now.strftime('%Y')}"]
    conditions << "product_details.warehouse_id=#{params[:branch_id]}"
    @product_mutations = ProductMutationHistory.joins(:product_detail).where(conditions.join(' AND ')).order('id')
    @product_mutation_histories = @product_mutations.group_by{|pmh|pmh.created_at.strftime('%d')}
    @stocks = {} 
    @last_stock = {}
    @product_mutation_histories.each{|pmh|
      pmh[1].each_with_index{|p, i|
        if @stocks["qty_#{pmh[0]}_#{p.mutation_type}"].present?
          @stocks["qty_#{pmh[0]}_#{p.mutation_type}"] += p.moved_quantity.to_i
          @stocks["price_#{pmh[0]}_#{p.mutation_type}"] += p.price.to_f
          if p.mutation_type == 'Sales' && p.discount.to_f > 0
            @stocks["price_#{pmh[0]}_Discount"] += p.discount.to_f
            @stocks["qty_#{pmh[0]}_Discount"] += p.moved_quantity.to_i
          end
        else
          @stocks["qty_#{pmh[0]}_#{p.mutation_type}"] = p.moved_quantity.to_i
          @stocks["price_#{pmh[0]}_#{p.mutation_type}"] = p.price.to_f
          if p.mutation_type == 'Sales' && p.discount.to_f > 0
            @stocks["price_#{pmh[0]}_Discount"] = p.discount.to_f
            @stocks["qty_#{pmh[0]}_Discount"] = p.moved_quantity.to_i
          end
        end
      }
      @last_stock[pmh[0]] = pmh[1].map(&:product_detail).uniq.map(&:available_qty).sum
      @last_stock[pmh[0]] = pmh[1].map(&:product_detail).uniq.map(&:available_qty).sum
    }
    respond_to do |format|
      format.html
      format.xls
      format.js
    end
  end

  def receiving
    @branches = Branch.all
    @u_receive = ReceivePurchaseTransfer.where("receiving_id is null").joins(:purchase_transfer).where("mutation_date BETWEEN '#{params[:year]}-#{params[:month]}-01 00:00:00' AND '#{"#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month.strftime('%Y-%m-%d 23:59:59')}'")
    @receivings = Receiving.where("date BETWEEN '#{params[:year]}-#{params[:month]}-01 00:00:00' AND '#{"#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month.strftime('%Y-%m-%d 23:59:59')}'")
    @receiving_details = ReceivingDetail.where("receivings.date BETWEEN '#{params[:year]}-#{params[:month]}-01 00:00:00' AND '#{"#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month.strftime('%Y-%m-%d 23:59:59')}'").joins(:receiving)
    @monthly_receivings = @receiving_details.group_by{|r|r.receiving.date.strftime('%B')}
    filename = "Receiving"
    filename << " #{params[:month]}/#{params[:year]}" if params[:month].present? && params[:year].present?
    respond_to do |format|
      format.html
      format.xls
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}.xlsx\"" }
    end
  end

  def forecast
    @bulan = []
    (8..12).each do |bln|
      @bulan << Date::MONTHNAMES[bln]
    end
    (1..7).each do |bln|
      @bulan << Date::MONTHNAMES[bln]
    end
    #@branches = Branch.all
    #@u_receive = ReceivePurchaseTransfer.where("receiving_id is null").joins(:purchase_transfer).where("mutation_date BETWEEN '#{params[:year]}-#{params[:month]}-01 00:00:00' AND '#{"#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month.strftime('%Y-%m-%d 23:59:59')}'")
    #@receivings = Receiving.where("date BETWEEN '#{params[:year]}-#{params[:month]}-01 00:00:00' AND '#{"#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month.strftime('%Y-%m-%d 23:59:59')}'")
    #@receiving_details = ReceivingDetail.where("receivings.date BETWEEN '#{params[:year]}-#{params[:month]}-01 00:00:00' AND '#{"#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month.strftime('%Y-%m-%d 23:59:59')}'").joins(:receiving)
    #@monthly_receivings = @receiving_details.group_by{|r|r.receiving.date.strftime('%B')}
    filename = "Forecast "
    filename << " #{params[:year]}" if params[:year].present?
    respond_to do |format|
      format.html
      format.xls
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}.xlsx\"" }
    end
  end

  def return_all_branch
    @branches = Branch.all
    @returns_to_hos = ReturnsToHo.all.group_by{|rth|rth.origin_warehouse_id}
    respond_to do |format|
      format.html
      format.xls
    end
  end
end
