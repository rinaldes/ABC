class User < ActiveRecord::Base
#  rolify
  has_many :knowledge_details
  has_many :pages, through: :allowable_pages
  has_many :allowable_pages
  has_many :sod_eods

  belongs_to :role
  belongs_to :head_office
  belongs_to :branch

  has_one :office, foreign_key: :contact_person
  has_one :flag_company
  has_one :api_key

  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:username], :reset_password_keys => [:username, :email]

  attr_accessor :password, :password_confirmation, :remember_me

  validates_confirmation_of :password
  validates_presence_of [:username, :role_id]
  validates_uniqueness_of [:username, :email]
  validates :head_office_id, presence: true, if: :should_have_head_office_id?
  # validates :branch_id, presence: true, if: :should_have_branch_id?

  before_save :encrypt_password

  def should_have_head_office_id?
    ![Role::CEO, Role::MANAGER, Role::MEMBER, Role::SUPPLIER].include?role_id
  end

  def current_offices
    branch_id.blank? ? (head_office_id.blank? ? Office.all : head_office.branches+[head_office]) : [branch]
  end

  def should_have_branch_id?
    ![Role::CEO, Role::MANAGER, Role::HEAD_ADMIN, Role::MEMBER, Role::SUPPLIER].include?role_id
  end

  #head_office_id AND branch_id IS NULL for CEO, Manager, Member, Supplier
  #branch_id IS NULL for Head Admin

=begin
[['Master Data', ['Manage Supplier', 'View Supplier', 'Manage Brand', 'View Brand', 'Manage Colour', 'View Colour', 'Manage Size', 'View Size', 'Manage Department', 'View Department',
  'Manage M-Class', 'View M-Class', 'Manage Member', 'View Member', 'Manage Unit', 'View Unit', 'Manage Bank', 'View Bank', 'Manage HO', 'View HO', 'Manage Branch', 'View Branch',
  'Manage Voucher', 'View Voucher', 'Manage Promo', 'View Promo']], ['Inventory', ['Manage Product', 'View Product', 'Daftar Barang Kosong & Min Stock', 'Cek Stock Semua Cabang',
  'Manage Stock Opname', 'View Stock Opname', 'Manage Transfer Barang', 'View Transfer Barang']], ['Purchasing', ['Manage Purchase Requisition', 'View Purchase Requisition',
  'Manage Purchase Order', 'View Purchase Order', 'Manage Receiving', 'View Receiving', 'Manage Return to Supplier', 'View Return to Supplier', 'Manage Return to HO',
  'View Return to HO', 'Manage Distribusi Barang', 'View Distribusi Barang']], ['Finance', ['Manage Petty Cash', 'View Petty Cash', 'Manage Account Payable', 'View Account Payable',
  'Manage Account Receivable', 'View Account Receivable'], ['Setting', ['Manage User', 'View User', 'Manage Role', 'View Role'], ['Dashboard', ['Live Report']]]]].each{|feature|
=end

  #http://localhost:3000/products?locale=en
  def can_view_product?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_PRODUCT, role_id)
  end

  def can_view_empty_stock?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_EMPTY_STOCK, role_id)
  end

  def can_view_min_stock?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_MIN_STOCK, role_id)
  end

  def can_view_stock_all_branches?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_STOCK_ALL_BRANCHES, role_id)
  end

  def can_view_stock_opname?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_STOCK_OPNAME, role_id)
  end

  def can_view_goods_transfer?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_GOOD_TRANSFER, role_id)
  end

  def can_view_stock_transfer?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_STOCK_TRANSFER, role_id)
  end

  def can_view_transfer_receipt?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_TRANSFER_RECEIPT, role_id)
  end

  def can_view_inventory?
    can_view_product? || can_view_empty_stock? || can_view_min_stock? || can_view_stock_all_branches? || can_view_stock_opname? || can_view_goods_transfer? || can_view_stock_transfer? || can_view_transfer_receipt?
  end

  def can_manage_product?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_PRODUCT, role_id)
  end

  def can_manage_unit?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_UNIT, role_id)
  end

  def can_manage_stock_opname?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_STOCK_OPNAME, role_id)
  end

  def can_manage_product_mutation?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_PRODUCT_MUTATION, role_id)
  end

  def can_manage_stock_mutation?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_STOCK_MUTATION, role_id)
  end

  def can_manage_mutation_receipt?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_MUTATION_RECEIPT, role_id)
  end

  def can_view_user?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_USER, role_id)
  end

  def can_view_to_do_list?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_TO_DO_LIST, role_id)
  end

  def can_manage_to_do_list?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_TO_DO_LIST, role_id)
  end

  def can_view_role?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_ROLE, role_id)
  end

  def can_view_setting?
    can_view_user? || can_view_role?
  end

  def can_manage_user?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_USER, role_id)
  end

  def can_manage_role?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_ROLE, role_id)
  end

  def can_view_sales_report?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_SALES_REPORT, role_id)
  end

  def can_view_cashier_report?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_CASHIER_REPORT, role_id)
  end

  def can_view_supplier?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_SUPPLIER, role_id)
  end

  def can_view_brand?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_BRAND, role_id)
  end

  def can_view_colour?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_COLOUR, role_id)
  end

  def can_view_size?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_SIZE, role_id)
  end

  def can_view_department?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_DEPARTMENT, role_id)
  end

  def can_view_mclass?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_MCLASS, role_id)
  end

  def can_view_member?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_MEMBER, role_id)
  end

  def can_view_member_level?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_MEMBER, role_id)
  end

  def can_view_unit?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_UNIT, role_id)
  end

  def can_view_bank?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_BANK, role_id)
  end

  def can_view_ho?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_HO, role_id)
  end

  def can_view_branch?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_BRANCH, role_id)
  end

  def can_view_voucher?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_VOUCHER, role_id)
  end

  def can_view_promo?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_PROMO, role_id)
  end

  def can_view_ar_voucher?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_AR_VOUCHER, role_id)
  end

  def can_view_master_data?
    can_view_supplier? || can_view_brand? || can_view_colour? || can_view_size? || can_view_department? || can_view_mclass? || can_view_member? || can_view_unit? || can_view_bank? || can_view_ho? || can_view_branch? || can_view_voucher? || can_view_promo? || can_view_ar_voucher?
  end

  def can_view_pr?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_PR, role_id)
  end

  def can_view_po?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_PO, role_id)
  end

  def can_view_receiving?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_RECEIVING, role_id)
  end

  def can_view_product_transfer?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_PRODUCT_TRANSFER, role_id)
  end

  def can_view_return_to_ho?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_RETURN_TO_HO, role_id)
  end

  def can_view_return_to_supplier?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_RETURN_TO_SUPPLIER, role_id)
  end

  def can_view_purchase?
    can_view_pr? || can_view_po? || can_view_receiving? || can_view_product_transfer? || can_view_return_to_ho? || can_view_return_to_supplier?
  end

  def can_manage_pr?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_PR, role_id)
  end

  def can_manage_voucher?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_VOUCHER, role_id)
  end

  def can_manage_department?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_DEPARTMENT, role_id)
  end

  def can_manage_branch?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_BRANCH, role_id)
  end

  def can_manage_ho?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_HO, role_id)
  end

  def can_manage_po?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_PO, role_id)
  end

  def can_manage_receiving?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_RECEIVING, role_id)
  end

  def can_manage_product_transfer?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_PRODUCT_TRANSFER, role_id)
  end

  def can_manage_supplier?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_SUPPLIER, role_id)
  end

  def can_manage_promo?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_PROMO, role_id)
  end

  def can_manage_return_to_supplier?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_RETURN_TO_SUPPLIER, role_id)
  end

  ######  Finance ######
  def can_view_account_payable?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_ACCOUNT_PAYABLE, role_id)
  end

  def can_manage_account_payable?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_ACCOUNT_PAYABLE, role_id)
  end

  def can_view_account_receivable?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_ACCOUNT_RECEIVABLE, role_id)
  end

  def can_manage_account_receivable?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_ACCOUNT_RECEIVABLE, role_id)
  end

  def can_view_budget?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_BUDGETING, role_id)
  end

  def can_manage_budget?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_BUDGETING, role_id)
  end

  def can_view_forecast?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_FORECAST, role_id)
  end

  def can_manage_forecast?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_FORECAST, role_id)
  end

  def can_view_petty_cash?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_PETTY_CASH, role_id)
  end

  def can_manage_petty_cash?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_PETTY_CASH, role_id)
  end

  def can_view_sod_eod?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_SOD_EOD, role_id)
  end

  def can_manage_sod_eod?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_SOD_EOD, role_id)
  end

  def can_manage_return_to_ho?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_RETURN_TO_HO, role_id)
  end

  def can_manage_brand?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_BRAND, role_id)
  end

  def can_manage_colour?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_BRAND, role_id)
  end

  def can_manage_size?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_SIZE, role_id)
  end

  def can_manage_mclass?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_M_CLASS, role_id)
  end

  def can_manage_member?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_MEMBER, role_id)
  end

  def can_manage_member_level?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_MEMBER, role_id)
  end

  def can_manage_bank?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_MEMBER, role_id)
  end

  def can_manage_ar_voucher?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::MANAGE_MEMBER, role_id)
  end

  ###### Finance Report ######
  def can_manage_bank_out_report?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::BANK_OUT_REPORT, role_id)
  end

  def can_manage_cash_out_report?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::CASH_OUT_REPORT, role_id)
  end

  def can_manage_global_finance_report?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::GLOBAL_FINANCE_REPORT, role_id)
  end

  def can_manage_journal_memo_report?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::JOURNAL_MEMO_REPORT, role_id)
  end

  def can_manage_account_payable_report?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::ACCOUNT_PAYABLE_REPORT, role_id)
  end

  def can_manage_store_cash_report?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::STORE_CASH_REPORT, role_id)
  end

  def can_manage_receivable_report?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::RECEIVABLE_REPORT, role_id)
  end

  def can_manage_repayment_report?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::REPAYMENT_REPORT, role_id)
  end

  def can_manage_denomination_report?
    Feature.find_by_feature_name_id_and_role_id(FeatureName::DENOMINATION_REPORT, role_id)
  end

  def office_id
    branch_id || head_office_id
  end

  def can_view_live_report
    Feature.find_by_feature_name_id_and_role_id(FeatureName::VIEW_LIVE_REPORT)
  end

  def offices
    return [branch] if branch.present?
    return head_office.branches+[head_office] if head_office.present?
    Office.all
  end

  def encrypt_password
    if password.present?
      self.encrypted_password = BCrypt::Password.create(password)
    else

    end
  end

  def fullname
    [first_name, last_name].join(' ')
  end

  def self.set_per_page(number)
    self.per_page = number
  end

  def company_code
   company = organization.company rescue nil
   "#{company.created_at.strftime("%Y%m%d%H%M%S")}#{company.id}" rescue ''
  end

  def name
    if self.first_name.present? and self.last_name.present?
  	  self.first_name + " " + self.last_name
    else
      return ''
    end
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |user|
        csv << user.attributes.values_at(*column_names)
      end
    end
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  private
    def build_default_flag
      # build_flag_company
    end
end
