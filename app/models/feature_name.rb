class FeatureName < ActiveRecord::Base
  VIEW_PRODUCT = 1
  VIEW_EMPTY_STOCK = 2
  VIEW_MIN_STOCK = 3
  VIEW_STOCK_ALL_BRANCHES = 4
  VIEW_STOCK_OPNAME = 5
  VIEW_GOOD_TRANSFER = 6
  VIEW_STOCK_TRANSFER = 7
  VIEW_TRANSFER_RECEIPT = 8
  MANAGE_PRODUCT = 9
  MANAGE_STOCK_OPNAME = 10
  MANAGE_PRODUCT_MUTATION = 12
  MANAGE_STOCK_MUTATION = 13
  MANAGE_MUTATION_RECEIPT = 14
  VIEW_PR = 15
  VIEW_PO = 16
  VIEW_RECEIVING = 17
  VIEW_RETURN_TO_SUPPLIER = 19
  VIEW_RETURN_TO_HO = 19
  VIEW_PRODUCT_TRANSFER = 20
  MANAGE_PR = 21
  MANAGE_PO = 22
  MANAGE_RECEIVING = 23
  MANAGE_RETURN_TO_SUPPLIER = 24
  MANAGE_RETURN_TO_HO = 25
  MANAGE_PRODUCT_TRANSFER = 26
  MANAGE_SUPPLIER = 50
  MANAGE_DEPARTMENT = 54
  MANAGE_HO = 59
  MANAGE_BRANCH = 60
  MANAGE_VOUCHER = 61
  MANAGE_PROMO = 62
  VIEW_SUPPLIER = 37
  VIEW_BRAND = 38
  VIEW_COLOUR = 39
  VIEW_SIZE = 40
  VIEW_DEPARTMENT = 41
  VIEW_MCLASS = 42
  VIEW_MEMBER = 43
  VIEW_MEMBER_LEVEL = 80
  VIEW_UNIT = 44
  VIEW_BANK = 45
  VIEW_HO = 46
  VIEW_BRANCH = 47
  VIEW_VOUCHER = 48
  VIEW_PROMO = 49
  MANAGE_BRAND = 51
  MANAGE_COLOUR = 52
  MANAGE_SIZE = 53
  MANAGE_MEMBER = 56
  MANAGE_MEMBER_LEEL = 81
  MANAGE_M_CLASS = 57
  VIEW_AR_VOUCHER = 64
  VIEW_USER = 65
  VIEW_ROLE = 66
  MANAGE_USER = 67
  MANAGE_ROLE = 68
  VIEW_LIVE_REPORT = 74
  VIEW_TO_DO_LIST = 78
  VIEW_CASHIER_REPORT = 94
  VIEW_SALES_REPORT = 97
  MANAGE_TO_DO_LIST = 79

  ### Finance
  VIEW_ACCOUNT_PAYABLE = 28
  MANAGE_ACCOUNT_PAYABLE = 33
  VIEW_ACCOUNT_RECEIVABLE = 29
  MANAGE_ACCOUNT_RECEIVABLE = 34
  VIEW_BUDGETING = 31
  MANAGE_BUDGETING = 36
  VIEW_FORECAST = 30
  MANAGE_FORECAST = 35
  VIEW_PETTY_CASH = 27
  MANAGE_PETTY_CASH = 32
  VIEW_SOD_EOD = 76
  MANAGE_SOD_EOD = 77
  MANAGE_UNIT = 59

  ### Finance Report
  BANK_OUT_REPORT = FeatureName.where(id: 80, :name => "Bank Out Report", :module_name => "Finance Report").first_or_create.id
  CASH_OUT_REPORT = FeatureName.where(id: 81, :name => "Cash Out Report", :module_name => "Finance Report").first_or_create.id
  GLOBAL_FINANCE_REPORT = FeatureName.where(id: 82, :name => "Global Finance Report", :module_name => "Finance Report").first_or_create.id
  JOURNAL_MEMO_REPORT = FeatureName.where(id: 83, :name => "Journal Memo Report", :module_name => "Finance Report").first_or_create.id
  ACCOUNT_PAYABLE_REPORT = FeatureName.where(id: 84, :name => "Account Payable Report", :module_name => "Finance Report").first_or_create.id
  STORE_CASH_REPORT = FeatureName.where(id: 85, :name => "Store Cash Report", :module_name => "Finance Report").first_or_create.id
  RECEIVABLE_REPORT = FeatureName.where(id: 86, :name => "Receivable Report", :module_name => "Finance Report").first_or_create.id
  REPAYMENT_REPORT = FeatureName.where(id: 87, :name => "Repayment Report", :module_name => "Finance Report").first_or_create.id
  DENOMINATION_REPORT = FeatureName.where(id: 88, :name => "Denomination Report", :module_name => "Finance Report").first_or_create.id
end
