#reset transaction
#Sale.delete_all;SalesDetail.delete_all;SodEod.delete_all;Session.delete_all;ProductMutationHistory.delete_all;ProductMutation.delete_all;ProductMutationDetail.delete_all;StockOpname.delete_all
#StockOpnameDetail.delete_all;StockTransfer.delete_all;StockTransferDetail.delete_all;Receiving.delete_all;ReceivingDetail.delete_all;ReturnsToSupplier.delete_all;ReturnsToSupplierDetail.delete_all

ActiveRecord::Base.connection.execute(
  "TRUNCATE TABLE size, size_details, colours, stock_opnames, stock_opname_details, receivings, receiving_details, product_mutations, product_mutation_details, product_mutation_histories, sales, sales_details, pr_transfer_products,
    returns_to_suppliers, returns_to_supplier_details, account_payables, account_payable_details, account_payable_receivings RESTART IDENTITY;
  UPDATE product_details SET available_qty=0, allocated_qty=0, freezed_qty=0, rejected_qty=0, defect_qty=0, online_qty=0;"
)

#ActiveRecord::Base.connection.execute("TRUNCATE TABLE stock_opnames, stock_opname_details RESTART IDENTITY;")

#-------=======Initial Data Start=======-------


['CEO', 'Kasir'].each{|role|
  role = Role.where(name: role).first_or_create
#  role.generate_accessable_pages
}

['Ricco Antonius', 'Dessy Firmansyah'].each_with_index{|user, i|
  User.create(first_name: user.split(' ')[0], last_name: user.split(' ')[1], gender: i < 1 ? 'Male' : 'Female', birth_place: "hometown", birth_date: "1992-12-12 00:00:00",
    email: "#{user.gsub(' ', '')}@gmail.com", status: "active", confirmed_at: Time.now, username: user.gsub(' ', '_').downcase, password: '12345678', role_id: i+1,
    pos_password: Digest::MD5.hexdigest('12345678')
  )
}

#ActiveRecord::Base.connection.execute("TRUNCATE TABLE features, feature_names;")
[{"id"=>1, "name"=>"View Product", "module_name"=>"Inventory"}, {"id"=>2, "name"=>"Daftar Barang Kosong", "module_name"=>"Inventory"}, {"id"=>3, "name"=>"Min Stock",
  "module_name"=>"Inventory"}, {"id"=>4, "name"=>"Cek Stock Semua Cabang", "module_name"=>"Inventory"}, {"id"=>5, "name"=>"View Stock Opname", "module_name"=>"Inventory"}, {"id"=>6,
  "name"=>"View Mutasi Barang", "module_name"=>"Inventory"}, {"id"=>7, "name"=>"View Mutasi Stock", "module_name"=>"Inventory"}, {"id"=>8, "name"=>"View Penerimaan Mutasi Barang",
  "module_name"=>"Inventory"}, {"id"=>9, "name"=>"Manage Product", "module_name"=>"Inventory"}, {"id"=>10, "name"=>"Manage Stock Opname", "module_name"=>"Inventory"}, {"id"=>12,
  "name"=>"Manage Mutasi Barang", "module_name"=>"Inventory"}, {"id"=>13, "name"=>"Manage Mutasi Stock", "module_name"=>"Inventory"},
  {"id"=>14, "name"=>"Manage Penerimaan Mutasi Barang", "module_name"=>"Inventory"}, {"id"=>15, "name"=>"View Purchase Requisition", "module_name"=>"Purchase"}, {"id"=>16,
  "name"=>"View Purchase Order", "module_name"=>"Purchase"}, {"id"=>17, "name"=>"View Receiving", "module_name"=>"Purchase"}, {"id"=>18, "name"=>"View Return to Supplier",
  "module_name"=>"Purchase"}, {"id"=>19, "name"=>"View Return to HO", "module_name"=>"Purchase"}, {"id"=>20, "name"=>"View Distribusi Barang", "module_name"=>"Purchase"}, {"id"=>21,
  "name"=>"Manage Purchase Requisition", "module_name"=>"Purchase"}, {"id"=>22, "name"=>"Manage Purchase Order", "module_name"=>"Purchase"}, {"id"=>23, "name"=>"Manage Receiving",
  "module_name"=>"Purchase"}, {"id"=>24, "name"=>"Manage Return to Supplier", "module_name"=>"Purchase"}, {"id"=>25, "name"=>"Manage Return to HO", "module_name"=>"Purchase"},
  {"id"=>26, "name"=>"Manage Distribusi Barang", "module_name"=>"Purchase"}, {"id"=>27, "name"=>"View Petty Cash", "module_name"=>"Finance"}, {"id"=>28,
  "name"=>"View Account Payable", "module_name"=>"Finance"}, {"id"=>29, "name"=>"View Account Receivable", "module_name"=>"Finance"}, {"id"=>30, "name"=>"View Forecast",
  "module_name"=>"Finance"}, {"id"=>31, "name"=>"View Budgeting", "module_name"=>"Finance"}, {"id"=>32, "name"=>"Manage Petty Cash", "module_name"=>"Finance"}, {"id"=>33,
  "name"=>"Manage Account Payable", "module_name"=>"Finance"}, {"id"=>34, "name"=>"Manage Account Receivable", "module_name"=>"Finance"}, {"id"=>35, "name"=>"Manage Forecast",
  "module_name"=>"Finance"}, {"id"=>36, "name"=>"Manage Budgeting", "module_name"=>"Finance"}, {"id"=>37, "name"=>"View Supplier", "module_name"=>"Master Data"}, {"id"=>38,
  "name"=>"View Brand", "module_name"=>"Master Data"}, {"id"=>39, "name"=>"View Colour", "module_name"=>"Master Data"}, {"id"=>40, "name"=>"View Size", "module_name"=>"Master Data"},
  {"id"=>41, "name"=>"View Department", "module_name"=>"Master Data"}, {"id"=>42, "name"=>"View M-Class", "module_name"=>"Master Data"}, {"id"=>43, "name"=>"View Member",
  "module_name"=>"Master Data"}, {"id"=>44, "name"=>"View Unit", "module_name"=>"Master Data"}, {"id"=>45, "name"=>"View Bank", "module_name"=>"Master Data"}, {"id"=>46,
  "name"=>"View HO", "module_name"=>"Master Data"}, {"id"=>47, "name"=>"View Branch", "module_name"=>"Master Data"}, {"id"=>48, "name"=>"View Voucher", "module_name"=>"Master Data"},
  {"id"=>49, "name"=>"View Promo", "module_name"=>"Master Data"}, {"id"=>50, "name"=>"Manage Supplier", "module_name"=>"Master Data"}, {"id"=>51, "name"=>"Manage Brand",
  "module_name"=>"Master Data"}, {"id"=>52, "name"=>"Manage Colour", "module_name"=>"Master Data"}, {"id"=>53, "name"=>"Manage Size", "module_name"=>"Master Data"}, {"id"=>54,
  "name"=>"Manage Department", "module_name"=>"Master Data"}, {"id"=>55, "name"=>"Manage M-Class", "module_name"=>"Master Data"}, {"id"=>56, "name"=>"Manage Member",
  "module_name"=>"Master Data"}, {"id"=>57, "name"=>"Manage Unit", "module_name"=>"Master Data"}, {"id"=>58, "name"=>"Manage Bank", "module_name"=>"Master Data"}, {"id"=>59,
  "name"=>"Manage HO", "module_name"=>"Master Data"}, {"id"=>60, "name"=>"Manage Branch", "module_name"=>"Master Data"}, {"id"=>61, "name"=>"Manage Voucher",
  "module_name"=>"Master Data"}, {"id"=>62, "name"=>"Manage Promo", "module_name"=>"Master Data"}, {"id"=>63, "name"=>"Manage AR Voucher", "module_name"=>"Master Data"}, {"id"=>64,
  "name"=>"View AR Voucher", "module_name"=>"Master Data"}, {"id"=>65, "name"=>"View User", "module_name"=>"Setting"}, {"id"=>66, "name"=>"View Role", "module_name"=>"Setting"},
  {"id"=>67, "name"=>"Manage User", "module_name"=>"Setting"}, {"id"=>68, "name"=>"Manage Role", "module_name"=>"Setting"}, {"id"=>69, "name"=>"Inventory Report",
  "module_name"=>"Report"}, {"id"=>70, "name"=>"Purchase Report", "module_name"=>"Report"}, {"id"=>71, "name"=>"Finance Report", "module_name"=>"Report"}, {"id"=>74,
  "name"=>"Live Report", "module_name"=>"Report"}, {"id"=>76, "name"=>"View SOD - EOD", "module_name"=>"Finance"}, {"id"=>77, "name"=>"Manage SOD - EOD", "module_name"=>"Finance"},
  {"id"=>78, "name"=>"Manage To Do List", "module_name"=>"Master Data"}, {"id"=>79, "name"=>"View To Do List", "module_name"=>"Master Data"}].each{|a|
  FeatureName.create a
}
User.first.role.generate_accessable_pages
['Manage Supplier', 'Manage Brand', 'Manage Colour', 'Manage Size', 'Manage Department', 'Manage M-Class', 'Manage Member', 'Manage Unit', 'Manage Bank', 'Manage HO',
  'Manage Branch', 'Manage Voucher', 'Manage Promo', 'Manage AR Voucher', 'View AR Voucher', 'Manage User', 'Manage Role'].each{|fn|
  Feature.create role_id: User.first.id, feature_name_id: FeatureName.where(name: fn).first_or_create.id
}

['View Supplier', 'View Brand', 'View Colour', 'View Size', 'View Department', 'View M-Class', 'View Member',
      'View Unit', 'View Bank', 'View HO', 'View Branch', 'View Voucher', 'View Promo', 'View User', 'View Role', 'Inventory Report', 'Purchase Report', 'Finance Report'].each{|fn|
  Feature.create role_id: User.first.id, feature_name_id: FeatureName.where(name: fn).first_or_create.id
}
Size.create description: 'ALL SIZE', code: 'S001'
Colour.create description: 'No Colour', code: 'C001'
GlobalSetting.create category: 'member_point_amount', name: 100000, description: '1 point seratus rebu', is_active: true
GlobalSetting.create category: 'sale_extra_charges', name: 'Katalog', description: '1 point seratus rebu', is_active: true
GlobalSetting.create category: 'sale_extra_charges', name: 'Jasa Kado', description: '1 point seratus rebu', is_active: true
GlobalSetting.create category: 'sale_extra_charges', name: 'CHARGE MARCHANT', description: '1 point seratus rebu', is_active: true
GlobalSetting.create category: 'sale_rounding', name: 'Rounding', description: '1 point seratus rebu', is_active: true


#-------=======Initial Data End=======-------

=begin
#for test only

#department
d1 = Department.where(name: 'SEPATU', code: '001').first_or_create
d2 = Department.where(name: 'SANDAL', code: '002').first_or_create

#office
h1 = HeadOffice.where(office_name: 'HO Bogor', description: 'HO Pusat Bogor', warehouse: 'Gudang HO Bogor', contact_person: User.first.id, phone_number: '08989898', fax_number: '08989898', mobile_phone: '08989898',
  address: 'Gedong Sawah', lat: '6.666', long: '7.7777').first_or_create
b1 = Branch.where(office_name: 'ABC 1', description: 'ABC 1 Bogor', warehouse: 'Gudang ABC 1', contact_person: User.first.id, phone_number: '08989898', fax_number: '08989898', mobile_phone: '08989898',
  address: 'Dewi Sartika', lat: '6.666', long: '7.7777')
b2 = Branch.where(office_name: 'ABC 2', description: 'ABC 2 Bogor', warehouse: 'Gudang ABC 2', contact_person: User.first.id, phone_number: '08989898', fax_number: '08989898', mobile_phone: '08989898',
  address: 'Dewi Sartika', lat: '6.666', long: '7.7777').first_or_create

#office_department
Department.all.each{|d|
  Office.all.each{|o|
    OfficeDepartment.create department_id: d.id, office_id: d.id,
  }
}

#supplier
s1 = Supplier.where(code: '001', name: 'Sugih Jaya', address: 'Sapan Rancakaso', city: 'Bandung', send_address: 'Sapan Rancakaso', phone: '08989899', fax: '089898991', hp1: '0898989912', email: 'sugih@jaya.com',
  send_city: 'Bandung', setup_discount: 30, hp2: '0898989911', pinbb: 'p121212', no_bill: '090909090', province: 'Jawa Barat', zip: '40123', suptype: 'Konsinyasi', long_term: 30).first_or_create
s2 = Supplier.where(code: '002', name: 'Sumber Kreasi', address: 'Sapan Rancakaso', city: 'Bandung', send_address: 'Sapan Rancakaso', phone: '08989899', fax: '089898991', hp1: '0898989912',
  email: 'sumber@kreasi.com', send_city: 'Bandung', setup_discount: 30, hp2: '0898989911', pinbb: 'p121212', no_bill: '090909090', province: 'Jawa Barat', zip: '40123', suptype: 'Konsinyasi',
  long_term: 30).first_or_create

#supplier_department
Supplier.all.each{|d|
  Department.all.each{|o|
    SupplierDepartment.create department_id: d.id, office_id: d.id,
    d.brands.create name: "ADIDAS#{o.id}#{d.id}", code: "#{o.id}#{d.id}", discount_percent1: 10, discount_percent2: 20, discount_percent3: 30, discount_percent4: 40, department_id: d.id, set_harga: 'Normal'
  }
}

Product.all.each{|product|
  product.size.size_details.each{|size_detail|
    ProductSize.create product_id: product.id, size_detail_id: size_detail.id
    Office.all.each{|branch|
      product_size = product.size
      product.update_attributes(size_id: Size.first.id) if product_size.blank?
      product.size.size_details.each{|size_detail|
        ProductDetail.create product_id: product.id, size_detail_id: size_detail.id, min_stock: 7, warehouse_id: branch.id, available_qty: 17, allocated_qty: 27, freezed_qty: 37,
          rejected_qty: 7, defect_qty: 21
      }
    }
  }
}

#Reset Transaction

Product Mutation, Product Transfer, Return to HO, all in one table product_mutations

All Product Mutation, from inventory, purchase or sales, per office per size are logged in product_mutation_histories

ActiveRecord::Base.connection.execute("TRUNCATE TABLE sales, sales_details, purchase_requests, purchase_request_details, purchase_orders, purchase_order_details, receivings,
  receiving_details, stock_transfers, stock_transfer_details, stock_opnames, stock_opname_details, product_mutations RESTART IDENTITY;")

After transaction
- change quantity
- logged in history

#Transaction Status:

Inventory==============================================================================================================================================================================
--------------------------------------------------------------------------Product Mutation---------------------------------------------------------------------------------------------
After Create -> Pending
After Received -> Closed

----------------------------------------------------------------------Product Mutation Receipt-----------------------------------------------------------------------------------------
After Create -> Ready For Inspection
After Inspection -> Inspected

=======================================================================================================================================================================================

Purchasing=============================================================================================================================================================================
----------------------------------------------------------------------------------Purchase Request-------------------------------------------------------------------------------------
After Create -> Pending
After Included in PO -> Approved
After Receive One Transfer -> On Progress
After Transfer Completed -> Closed

----------------------------------------------------------------------------------Purchase Order---------------------------------------------------------------------------------------
After Create -> Waiting Approval
After Approved -> Approved/Rejected
After One Receive -> On Progress
After Receiving Completed -> Closed

---------------------------------------------------------------------------------------Receiving---------------------------------------------------------------------------------------
After Create -> Ready For Inspection
After Inspection -> Inspected
After Paid All -> Closed

-----------------------------------------------------------------------------------Product Transfer------------------------------------------------------------------------------------
After Create -> Pending
After Received by Branch -> Closed

-------------------------------------------------------------------------------Product Transfer Receipt--------------------------------------------------------------------------------
After Create -> Ready For Inspection
After Inspection -> Inspected

------------------------------------------------------------------------------------ReturnsToSupplier----------------------------------------------------------------------------------
After Create -> On Progress
After Complete -> Closed
=======================================================================================================================================================================================

=end
