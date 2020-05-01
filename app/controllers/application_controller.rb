class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_filter :set_locale
  before_filter :set_current_user

  # def authenticate_user!
  #   return User.first
  # end


  def not_authorized
    flash[:error] = 'You dont have authorize on this'
    return redirect_to root_url
  end

  def load_departments
    @departments = MClass.where("parent_id IS NULL").select("name, id").order("name")
  end

  def get_paginated_sizes
    conditions = []
    conditions << "sizes.updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @sizes = Size.joins("INNER JOIN size_details ON sizes.id=size_details.size_id").where(conditions.join(' AND ')).order(default_order('sizes')).uniq
      .paginate(page: params[:page], :per_page => 10) || []
  end

  def get_paginated_branches
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @branches = Branch.joins("LEFT JOIN users ON offices.contact_person=users.id LEFT JOIN offices head_offices ON head_offices.id=offices.head_office_Id")
      .select("offices.*, users.username, head_offices.office_name AS head_office_name").where(conditions.join(' AND ')).order(default_order('offices')).paginate(page: params[:page], per_page: 10) || []
  end

  def get_paginated_size_details
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @size_details = SizeDetail.where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' ')).uniq
      .paginate(page: params[:page], :per_page => 10) || []
  end

  def get_paginated_members
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @members = Member.joins("LEFT JOIN member_types ON members.member_type_id=member_types.id").where(conditions.join(' AND ')).select("members.*, to_char(birthday, 'DD-MM-YYYY'), member_types.name as member_type_name").order(default_order('members'))
      .paginate(page: params[:page], per_page: 10)
  end

  def get_paginated_member_levels
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @member_levels = MemberLevel.where(conditions.join(' AND ')).select("*").order(default_order('member_levels'))
      .paginate(page: params[:page], per_page: 10)
  end

  def get_paginated_products
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @products = Product.joins(:m_class, :colour, :size, brand: :supplier).where(conditions.join(' AND '))
      .select("brands.name AS brand_name, suppliers.name AS supplier_name, colours.name AS colour_name, m_classes.name AS m_class_name, products.*, sizes.description AS size_name,
      to_char(selling_price, '99999999D99') AS selling_price, to_char(purchase_price, '99999999D99') AS purchase_price")
      .order((params[:sort] || 'updated_at').to_s.gsub('-', ' ')).paginate(page: params[:page], per_page: 10) || []
  end

  def get_paginated_member_types
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @member_types = MemberType.where(conditions.join(' AND ')).order(default_order('member_types')).paginate(:page => params[:page], :per_page => 10) || []
  end

  def get_paginated_catalogs
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @catalogs = Catalog.where(conditions.join(' AND ')).order(default_order('catalogs')).paginate(:page => params[:page], :per_page => 10) || []
  end

  def get_paginated_petty_cash_types
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @petty_cash_types = PettyCashType.where(conditions.join(' AND ')).order(default_order('petty_cash_types')).paginate(:page => params[:page], :per_page => 10) || []
  end

  def get_paginated_cashbacks
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @cashbacks = Cashback.where(conditions.join(' AND ')).order(default_order('cashbacks')).paginate(:page => params[:page], :per_page => 10) || []
  end

  def get_paginated_colours
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @colours = Colour.where(conditions.join(' AND ')).order(default_order('colours')).paginate(:page => params[:page], :per_page => 10) || []
  end

  def get_paginated_to_do_lists
    conditions = []
    conditions << "updated_at >= '#{params[:last_update]}'" if params[:last_update].present?
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @to_do_lists = ToDoList.where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' ')).paginate(:page => params[:page], :per_page => 10) || []
  end

  def load_supplier
    @suppliers = Supplier.select("name, id, address, code").limit(7).order("name")
  end

  def get_paginated_brands
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
    } if params[:search].present?
    @brands = Brand.where(conditions.join(' AND ')).joins(:supplier, :department)
      .select("brands.id, brands.code, brands.name, brands.set_harga, suppliers.code AS supplier_code, suppliers.name AS supplier_name, to_char(discount_percent1, '99D99') AS discount_percent1,
        to_char(discount_percent2, '99D99') AS discount_percent2, to_char(discount_percent3, '99D99') AS discount_percent3, to_char(discount_percent4, '99D99') AS discount_percent4,
        discount_rp, m_classes.name AS department_name")
      .order(default_order('brands')).paginate(page: params[:page], per_page: 10) || []
  end

  def default_order module_name=nil
    (params[:sort] || "#{module_name}#{'.' if module_name.present?}created_at DESC").to_s.gsub('-', ' ')
  end

  def romanian_month
    date = Date.today
    case date.month
      when 1
        result = "I"
      when 2
        result = "II"
      when 3
        result = "III"
      when 4
        result = "IV"
      when 5
        result = "V"
      when 6
        result = "VI"
      when 7
        result = "VII"
      when 8
        result = "VIII"
      when 9
        result = "IX"
      when 10
        result = "X"
      when 11
        result = "XI"
      when 12
        result = "XII"
      else
        result = "undefined"
    end
    return "#{result}/#{date.strftime("%y")}"
  end

  def authenticate_admin
    unless current_user.role == "admin"
      redirect_to root_path, :notice => "Authenticated admin needed here!"
    end
  end

  def set_locale
    session[:language] = 'en' unless session[:language]
    I18n.locale = session[:language]
    Rails.application.routes.default_url_options[:locale]= I18n.locale
  end

  def admin_authentication
    unless current_admin
      redirect_to admin_root_path, :notice => "Authenticated admin needed here!"
    end
  end

  def admin_authenticate
    if current_admin
      redirect_to admin_dashboard_path, :notice => "Already logged in as #{current_admin.email}!"
    end
  end

  def set_current_user
    User.current = current_user
    @current_user = current_user
    PettyCash.generate_petty_cashes(Time.now.year, Time.now.month)
    @entity = Entity.where(domain_name: request.env['HTTP_HOST']).first_or_create
    @entity = Entity.first
  end

  private
  def current_admin
    @current_admin ||= Admin.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
    # @current_admin ||= Admin.find(session[:admin_id]) if session[:admin_id]
  end

end
