class Api::DesktopApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :check_current_user, :check_permitted_page
  skip_before_filter :protect_from_forgery
  skip_before_filter :authenticate_user!
  before_filter :check_token, except: [:pos_machines_list, :users, :roles, :branches_list, :warehouse_list]
  before_filter :check_params, :only => [:create_sales, :create_refund_order, :create_exchange_order, :create_ptb]

  def discount_histories
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    @promotions = DiscountHistory.where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' ')) rescue []
    render json: @promotions.map{|promo|promo.attributes.merge(complete_image_url: "http://#{request.env['HTTP_HOST']}#{product.image.url}",
      discount_details: promo.discount_history_details)}
  end

  def product_promo_discounts
    hash = []
    product = Product.find_by_id(params[:id])
    branch = Branch.find_by_id(params[:branch_id])
    return render json: [] if product.blank? || branch.blank?
    promotions = PromoItemList.where(
      "department_id=#{product.brand.department_id} OR m_class_id=#{product.m_class_id} OR brand_id=#{product.brand_id} OR article_id='#{product.article}'"
    )
    render json: Promotion.where(
      "now() BETWEEN \"from\" AND \"to\" AND office_id IN (#{branch.id}, #{branch.head_office_id}) AND id IN (#{promotions.map(&:promotion_id).push(0).join(', ')})"
    ).map{|promo|
      promo.attributes.merge(
        promo_item_lists: promo.promo_item_lists.map{|pi|
          pi.attributes.merge(department_name: (pi.department.name rescue nil), brand_name: (pi.brand.name rescue nil), m_class_name: (pi.m_class.name rescue nil))
        },
        prize_lists: promo.prize_lists.map{|pi|
          pi.attributes.merge(department_name: (pi.department.name rescue nil), brand_name: (pi.brand.name rescue nil), m_class_name: (pi.m_class.name rescue nil))
        }
      )
    }
  end

  def member_levels
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    @promotions = MemberLevel.where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' '))
    render json: @promotions
  end

  def promotions_list
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    conditions << "office_id='#{params[:branch_id]}'" if params[:branch_id].present?
    @promotions = Promotion.where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' ')).joins(:office).select("promotions.*, offices.office_name AS branch_name")
    render json: @promotions.map{|promo|promo.attributes.merge(promo_item: promo.promo_item_lists, prize: promo.prize_lists)}
  end

  def promo_items_list
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    @promotions = PromoItemList.where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' '))
    render json: @promotions
  end

  def prizes_list
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    @promotions = PrizeList.where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' '))
    render json: @promotions
  end

  def index
    members = Member.all_to_api_request(params)

    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    conditions << "brands.updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    @brands = Brand.where(conditions.join(' AND ')).joins(:supplier)
      .select("brands.id, brands.code, brands.name, suppliers.code AS supplier_code, suppliers.name AS supplier_name, discount_percent1, discount_percent2, discount_percent3,
        discount_percent4, discount_rp").order(params[:sort].to_s.gsub('-', ' '))

    get_paginated_colours
    get_paginated_sizes
    get_paginated_size_details

    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @departments = MClass.where("parent_id IS NULL").where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' '))

    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @mclasses = MClass.where("parent_id IS NOT NULL").where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' '))

    conditions = []
    conditions << "offices.updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @branches = Office.joins("LEFT JOIN users ON offices.contact_person=users.id").select("offices.*, users.username").where(conditions.join(' AND '))
      .order(params[:sort].to_s.gsub('-', ' '))

    conditions = []
    conditions << "products.updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'" if param[1].present?
    } if params[:search].present?
    @products = Product.joins(:m_class, :colour, :size, brand: :supplier).where(conditions.join(' AND '))
      .select("brands.name AS brand_name, suppliers.name AS supplier_name, colours.name AS colour_name, m_classes.name AS m_class_name, products.*, sizes.description AS size_name,
      to_char(selling_price, '99999999D99') AS selling_price, to_char(purchase_price, '99999999D99') AS purchase_price").order(params[:sort].to_s.gsub('-', ' '))

    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @edc_machines = EdcMachine.where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' '))

    render json: {
      members: members, brands: @brands, colours: @colours, departments: @departments, m_classes: @mclasses,
      warehouses: @branches.map{|branch|branch.attributes.merge(type: branch.class.to_s)}, sizes: @sizes, size_details: @size_details, banks: @edc_machines
    }
  end

  def edc_bank_account_list
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    render json: EdcBankAccount.where(conditions.join(' AND '))
  end

  def users
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    render json: User.where(conditions.join(' AND '))
  end

  def price_per_branch
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    conditions << "branch_id='#{params[:branch_id]}'" if params[:branch_id].present?
    render json: BranchPrice.where(conditions.join(' AND ')).to_json
  end

  def members
    if params[:member_id].present?
      member = Member.find_by_id(params[:member_id])
      render json: member.attributes.merge(member_level: member.member_level).to_json
    else
      render json: Member.all_to_api_request(params)
    end
  end

  def lock_member
    member = Member.find_by_id(params[:member_id])
    result = member.update_attributes(locked_by: params[:pos_machine_id])
    render json: {status: result ? 'success' : 'failed', errors: member.errors.full_messages}
  end

  def pos_machines_list
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @mclasses = PosMachine.where(conditions.join(' AND ')).offset(params[:offset]).limit(params[:limit]).order("pos_machines.updated_at ASC")
    render json: @mclasses
  end

  def size_list
    get_paginated_sizes
    render json: @sizes
  end

  def size_details_list
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @mclasses = SizeDetail.where(conditions.join(' AND ')).offset(params[:offset]).limit(params[:limit]).order("size_details.updated_at ASC")
    render json: @mclasses
  end

  def branches_list
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @branches = Office.joins("LEFT JOIN users ON offices.contact_person=users.id").select("offices.*, users.username").where(conditions.join(' AND '))
      .order(params[:sort].to_s.gsub('-', ' ')).paginate(page: params[:page], per_page: 10) || []
    render json: @branches
  end

  def m_class_list
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @mclasses = MClass.where(conditions.join(' AND ')).offset(params[:offset]).limit(params[:limit]).order("m_classes.updated_at ASC")
    render json: @mclasses
  end

  def department_list
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @mclasses = MClass.where("parent_id IS NULL").where(conditions.join(' AND ')).offset(params[:offset]).limit(params[:limit]).order("m_classes.updated_at ASC")
    render json: @mclasses
  end

  def product_detail_list
    conditions = ["barcode_size IS NOT NULL"]
    conditions << "product_id IN (#{params[:product_id]})" if params[:product_id].present?
    conditions << "product_details.updated_at > '#{params[:last_update]}'" if params[:last_update].present?
    conditions << "warehouse_id='#{params[:warehouse_id]}'" if params[:warehouse_id].present?
    render json: ProductDetail.where(conditions.join(' AND ')).joins(product_size: :product).offset(params[:offset]).limit(params[:limit]).order("product_details.updated_at ASC")
      .select("product_details.*, product_size_id AS product_size")
  end

  def product_size_list
    conditions = ["barcode_size IS NOT NULL"]
    conditions << "product_sizes.updated_at > '#{params[:last_update]}'" if params[:last_update].present?
    render json: ProductSize.where(conditions.join(' AND ')).offset(params[:offset]).limit(params[:limit]).order("product_sizes.updated_at ASC")
  end

  def colours_list
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    render json: Colour.where(conditions.join(' AND ')).offset(params[:offset]).limit(params[:limit]).order("colours.updated_at ASC")
  end

  def warehouse_list
    conditions = ["type='Branch'"]
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @branches = Office.joins("LEFT JOIN users ON offices.contact_person=users.id").select("offices.*, users.username").where(conditions.join(' AND '))
      .order(params[:sort].to_s.gsub('-', ' ')).paginate(page: params[:page], per_page: 10) || []
    render json: @branches.map{|branch|branch.attributes.merge(type: branch.class.to_s)}
  end

  def product_stock
    conditions = []
    conditions = ["products.id=#{params[:product_id]}"] if params[:product_id].present?
    @current_user = User.first
    @current_offices = current_user.offices
    if params[:search].present?
      @brand = Brand.find_by_name params[:search][:brand]
      params[:search].each{|param|
        if param[0] == "status3" or param[0] == "status4"
          params[:search][param[0]].each{|status|
            conditions << "#{param[0]} = '#{status[1]}'"
          }
        end
      }
      if @brand.present?
        @supplier = @brand.supplier
        @products = @brand.products.where(conditions.join(' OR ')).group_by{|product|product.m_class.department.id}
        @departments = MClass.where(id: @products.keys.join(','))
      end
      @offices = Office.where(id: params[:search][:branch].keys)
    else
      @offices = current_user.offices
    end
    render template: "products/stock"#, layout: false
  end

  def brands_list
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @brands = Brand.where(conditions.join(' AND ')).joins(:supplier).offset(params[:offset]).limit(params[:limit])
      .select("brands.id, brands.code, brands.name, suppliers.code AS supplier_code, suppliers.name AS supplier_name, discount_percent1, discount_percent2, discount_percent3, discount_percent4, discount_rp")
      .order("brands.updated_at ASC") || []
    render json: @brands
  end

  def member_balance_mutations_list
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @member_balance_mutations = MemberBalanceMutation.where(conditions.join(' AND ')).offset(params[:offset]).limit(params[:limit]).order("member_balance_mutations.updated_at ASC")
    render json: @member_balance_mutations
  end

  def member_point_mutations_list
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @member_point_mutations = MemberPointMutation.where(conditions.join(' AND ')).offset(params[:offset]).limit(params[:limit]).order("member_Point_mutations.updated_at ASC")
    render json: @member_point_mutations
  end

  def vouchers_list
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @vouchers = Voucher.where(conditions.join(' AND ')).offset(params[:offset]).limit(params[:limit]).order("vouchers.updated_at ASC").select("vouchers.*, type AS voucher_type")
    render json: @vouchers
  end

  def voucher_details_list
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @vouchers = VoucherDetail.where(conditions.join(' AND ')).offset(params[:offset]).limit(params[:limit]).order("voucher_details.updated_at ASC")
    render json: @vouchers
  end

  def supplier_list
    data, total = Supplier.with_filtering(params)
    respond(data, total, params)
  end

  def product_list
    conditions = []
    conditions << "products.updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'" if param[1].present?
    } if params[:search].present?
    @products = Product.joins(:m_class, :colour, :size, brand: :supplier).where(conditions.join(' AND ')).offset(params[:offset]).limit(params[:limit]).order("products.updated_at ASC")
      .select("products.*, brands.name AS brand_name, suppliers.name AS supplier_name, colours.name AS colour_name, m_classes.name AS m_class_name, products.*, sizes.description AS size_name,
      selling_price, purchase_price")
    render json: @products.map{|product|product.attributes.merge(department_id: product.m_class.department.id, unit_name: product.unit.name,
      complete_image_url: "http://#{request.env['HTTP_HOST']}#{product.image.url}")}
  end

  def cashback
    render json: (Cashback.find_by_member_level_id(params[:member_level_id]).attributes rescue nil)
  end

  def create_sod_eod
    param = ActiveSupport::JSON.decode(params[:sod_eod])
    SodEod.create sod_eod_date: param['start_time'], office_id: param['office_id'], start_amount: param['start_amount'], user_id: param['user_id'], session: param['shift_no'],
      created_at: Time.at(param['created_at'].chop.chop.chop.to_i), updated_at: Time.at(param['updated_at'].chop.chop.chop.to_i), machine_id: param['client_id'],
      start_time: Time.at(param['start_time'].chop.chop.chop.to_i), end_time: Time.at(param['end_time'].chop.chop.chop.to_i), start_100k: param['start_100k'], start_50k: param['start_50k'],
      start_20k: param['start_20k'], start_10k: param['start_10k'], start_5k: param['start_5k'], start_2k: param['start_2k'], start_1k: param['start_1k'], start_500: param['start_500'],
      start_200: param['start_200'], start_100: param['start_100'], start_50: param['start_50'], end_100k: param['end_100k'], end_50k: param['end_50k'], end_20k: param['end_20k'], end_10k: param['end_10k'],
      end_5k: param['end_5k'], end_2k: param['end_2k'], end_1k: param['end_1k'], end_500: param['end_10k'], end_200: param['end_200'], end_100: param['end_100'], end_50: param['end_50'],
      total_sales: param['total_sales'], debit: param['debit'], credit: param['credit'], transfer: param['transfer'], voucher: param['voucher'], retur: param['retur'], discount: param['discount'],
      special_discount: param['special_discount'], paid_difference: param['paid_difference'], ppn: param['ppn'], receipt_count: param['receipt_count'], cash: params['cash'], session_type: param['session_type']
    render json: {status: 'success'}
  end

  def create_session
    param = ActiveSupport::JSON.decode(params['start_shift'] || params['session'])
    param_det = param['sodeod']
    begin
      SodEod.create sod_eod_date: Time.at(param['start_time'].to_s.chop.chop.chop.to_i), office_id: param['office_id'], end_amount: param_det['end_amount'], start_amount: param_det['start_amount'],
        user_id: param['user_id'], session: param['shift_no'], created_at: Time.at(param['created_at'].to_s.chop.chop.chop.to_i), updated_at: Time.at(param['updated_at'].to_s.chop.chop.chop.to_i),
        machine_id: param['client_id'], start_time: Time.at(param['start_time'].to_s.chop.chop.chop.to_i), end_time: Time.at(param_det['end_time'].to_s.chop.chop.chop.to_i), start_100k: param_det['start_100k'],
        start_50k: param_det['start_50k'], start_20k: param_det['start_20k'], start_10k: param_det['start_10k'], start_5k: param_det['start_5k'], start_2k: param_det['start_2k'], start_1k: param_det['start_1k'],
        start_500: param_det['start_500'], start_200: param_det['start_200'], start_100: param_det['start_100'], start_50: param_det['start_50'], end_100k: param_det['end_100k'], end_50k: param_det['end_50k'],
        end_20k: param_det['end_20k'], end_10k: param_det['end_10k'], end_5k: param_det['end_5k'], end_2k: param_det['end_2k'], end_1k: param_det['end_1k'], end_500: param_det['end_10k'],
        end_200: param_det['end_200'], end_100: param_det['end_100'], end_50: param_det['end_50'], total_sales: param_det['total_sales'], debit: param_det['debit'], credit: param_det['credit'],
        transfer: param_det['transfer'], voucher: param_det['voucher'], retur: param_det['retur'], discount: param_det['discount'], special_discount: param_det['special_discount'],
        paid_difference: param_det['paid_difference'], ppn: param_det['ppn'], receipt_count: param_det['receipt_count'], cash: param_det['cash'], session_type: param_det['session_type'],
        actual_end_amount: param_det['actual_end_amount'], difference: param_det['difference']
    rescue
    end
    render json: {status: 'success'}
  end

  def transaction
    if params[:voucher_code].present? && ArVoucherDetail.find_by_code(params[:voucher_code]).blank?
      render json: {status: 'failed', message: 'Voucher code invalid'}, status: 200
    else
      param = ActiveSupport::JSON.decode(params['sale_transactions'])
      sales_detail = param['items']
      total_quantity = sales_detail.map{|sale_detail|sale_detail['quantity']}.sum
      member_param = param['member']
      if member_param.present?
        member = Member.find(member_param['id'])
        if member.blank?
          member = Member.new card_number: rand.to_s.reverse[1..7], name: member_param[:name], address: member_param[:address], birthday: member_param[:birthday], phone_number: member_param[:phone_number],
            gender: member_param[:gender], hp: member_param[:hp], code: Member.last.code.to_i+1, city: member_param[:city], zip: member_param[:zip], datemember: member_param[:join_date], is_valid: true,
            discount: 0, active: true, email: member_param[:email], balance: 0, member_level_id: nil, point: 0
          member.save
        end
      end
      sale = Sale.new(code: param['code'], payment_type: param['payment_type'], transaction_date: Time.at(param['transaction_date'].to_s.chop.chop.chop.to_i), sales_bill_id: param['sales_bill_id'],
        member_id: (member.id rescue nil), client_id: param['client_id'], bill_number: param['bill_number'], store_id: param['branch_id'], total_price: param['total_price'],
        total_discount: param['total_discount'], user_id: param['user_id']['id'], voucher_code: param['voucher_code'], total_paid: param['total_paid'], total_outstanding: param['total_outstanding'],
        total_quantity: total_quantity, total_capital: (sales_detail.map{|sale_detail| (ProductSize.find(sale_detail['product_size_id']).product.cost_of_products rescue 0).to_f}.sum * total_quantity rescue 0),
        subtotal_price: param['subtotal_price'], payment_cash: param['payment_cash'], exchange: param['exchange'], status: param['status'], voucher_amt: param['voucher_amt'], debit_id: param['debit_id'],
        credit_id: param['credit_id'], transfer_id: param['transfer_id'], transfer_amt: param['transfer_amt'], debit_amt: param['debit_amt'], credit_amt: param['credit_amt'], cashback_id: param['cashback_id'],
        cashback_amt: param['cashback_amt'], total_extra_charge: param['total_extra_charge'], rounding_amt: param['rounding_amt'], earned_voucher_id: param['earned_voucher_id'],
        total_special_discount: param['total_special_discount'], session_id: param['session_id'], total_ppn: param['total_ppn'], receipt_count: param['receipt_count'], p2p_amt: param['p2p_amt'],
        total_claim: param['total_claim'], id: Sale.last.id+1, btp_masuk: param['btp_masuk'], btp_keluar: param['btp_keluar'])
      sale.save
      VoucherDetail.find_by_voucher_code(param['used_voucher']['voucher_code']).update_attributes(order_no: param['used_voucher']['order_no'], available: false, member_id: member.id) rescue ''
      param['items'].each{|sd|
        sale.sales_details.create sd.delete_if{|d|%w(specialDisc itemNo initPrice discAmt discPct discPrice).include?(d)}.merge(
          store_id: param[:store_id], id: (SalesDetail.last.id rescue 0)+1
        )
      }
      if member_param.present?
        member_param['balances'].each{|sd|
          member.member_balance_mutations.create! sd.delete_if{|d|%w(memberId).include?(d)}.merge(id: (MemberBalanceMutation.last.id.to_i rescue 0)+1)
        } if member_param['balances'].present?
        member_param['points'].each{|sd|
          member.member_point_mutations.create! sd.delete_if{|d|%w(memberId).include?(d)}.merge(id: (MemberPointMutation.last.id.to_i rescue 0)+1)
        } if member_param['points'].present?
      end
      render json: {status: 'success'}, status: 201
    end
  end

  def voucher
    voucher = Voucher.find_by_code(params[:code])
    render json: voucher
  end

  def use_promo
    prize = PrizeList.find_by_id(params[:id])
    render json: {success: (prize.update_attributes(available_qty: prize.available_qty-params[:used_qty].to_i))}
  end

  def voucher_details
    voucher = VoucherDetail.find_by_voucher_code(params[:code])
    v_tohash = voucher.attributes
    vd = VoucherDetail.where(voucher_code: params[:code])
    parent_voucher = voucher.voucher
    parent_voucher.attributes.each{|v|
      v_tohash = v_tohash.merge("parent_#{v[0]}" => v[1])
    }
    render json: v_tohash.merge(parent_offices: parent_voucher.office.class == HeadOffice ? parent_voucher.office.branches : [parent_voucher.office])
  end

  def roles
    render json: Role.all.map{|role|role.attributes.merge(features: role.feature_names)}
  end

  def entities_list
    render json: Entities.all
  end

  def unit_list
    render json: Unit.all
  end

  def bank_list
    render json: {data: EdcMachine.all}
  end

  def branch_list
    data = []
    data_index = Office.all
    data_index.each do |branch|
      detail = branch.get_branch_detail
      data << detail
    end
    render json: { data: data }.to_json, status: 200
  end

  private
    def render_json(result)
      if result.include?("Can't find sales") || result.blank?
        render json: {status: 'failed', :message => result}
      else
        render json: {status: 'success'}
      end
    end

    def check_params
      if params[:data].blank?
        params[:data] = request.body.read
      end
    end

    def check_token
      #example params[:token]=
      access_token = ApiKey.find_by_access_token(params[:token])
      unless access_token
        render :json => {message: "Token invalid", status: 401}, status: 401
      end
    end

    def respond(data, total, params)
      respond_to do |format|
        format.json { render json: { data: data, total_count: total }.to_json, status: 200 }
        format.pdf { send_data pdf_generator(data, params[:header], params[:title]), type: 'application/pdf', status: 200 }
        format.xls { send_data excel_generator(data, params[:header], params[:title]), type: 'application/vnd.ms-excel', status: 200 }
      end
    end
end
