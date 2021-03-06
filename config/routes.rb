Rails.application.routes.draw do
  get'product_mutation_history/' => 'product_mutation_history#index'
  get'product_mutation_history/:product_detail_id' => 'product_mutation_history#index'
  namespace :store_admin_reports do
    resources :sales_per_m_classes, only: [:index]
    resources :sales_realizations, only: [:index]
    resources :revenues, only: [:index]
    resources :discounts, only: [:index]
    resources :omsets, only: [:index]
    resources :eods, only: [:index]
  end
  namespace :warehouse_admin_reports do
    resources :surat_jalans, only: [:index]
    resources :global_pencocokan_returs, only: [:index]
  end
  resources :kedatangan_barang, only: [:index] do
    get :export
  end
  resources :report_transferan, only: [:index] do
    get :export
  end
  namespace :finance_reports do
    resources :bank_outs, only: [:index, :show] do
      collection do
        get :export
      end
    end
    resources :cash_outs, only: [:index] do
      collection do
        get :export
      end
    end
    resources :global_finances, only: :index do
      collection do
        get :export
      end
    end
    resources :journal_memos, only: :index do
      collection do
        get :brands_per_supplier
        get :export
      end
    end
    resources :account_payables, only: :index do
      collection do
        get :export
      end
    end
    resources :sisa_hutang_dagang, only: :index do
      collection do
        get :export
      end
    end
    resources :report_azzurra, only: :index do
      collection do
        get :export
      end
    end
    resources :store_cashs, only: :index do
      collection do
        get :export
      end
    end
    resources :receivables, only: :index do
      collection do
        get :export
      end
    end
    resources :repayments, only: :index do
      collection do
        get :export
      end
    end
    resources :denominations, only: :index do
      collection do
        get :export
      end
    end
  end

  resources :selling_prices do
    collection do
      post :import
      get :search_product_manual
      get :search_in_modal
      get :fitur_filter
    end
  end

  namespace :finances do
    resources :cash_outs, only: [:new, :create, :show, :edit, :update]
    resources :petty_cashes
    resources :sod_eods do
      collection do
        get :add_input
      end
    end
    resources :monthly_payments
    resources :account_payables do
      member do
        get :print_to_pdf
      end
    end
    resources :account_receivables
    resources :forecasts do
      resources :monthly_forecasts
    end
    resources :budgetings
  end
  get 'get_branches' => 'finances/petty_cashes#get_branches', :as => :get_branches

  namespace :finances do
    resources :petty_cash
  end

  resources :product_details
  resources :transaction_histories do
    collection do
      get :search
    end
  end

  resources :ar_vouchers do
    collection do
      get :add_payment
    end
  end

  resources :products do
    collection do
      get :stock
      get :add_branch
      get :add_m_class
      get :autocomplete_goods_barcode
      get :mclass_per_department
      get :transaction_history
      post :import
    end
  end

  resources :change_barcodes

  resources :edc_bank_accounts do
    collection do
      post :import
    end
  end
  resources :edc_machines do
    collection do
      post :import
    end
  end
  resources :head_offices do
    collection do
      get :autocomplete_head_office_office_name
      post :import
    end
  end

  resources :branches do
    collection do
      get :autocomplete_branch_office_name
      post :import
    end
  end
  resources :vouchers
  resources :promos
  resources :stock_transfers do
    collection do
      get :search
      get :autocomplete_stock_transfer_name
      get :add_brand
      get :add_product
      get :get_last_number
    end
    member do
      get :print_to_pdf
    end
  end

  resources :units do
    collection do
      get :autocomplete_unit_name
      post :import
    end
  end

  resources :report_finances do
    collection do
      get :pembayaran_per_bulan
    end
  end

  resources :m_classes do
    collection do
      get :autocomplete_m_class_name
      get :add_sub_m_class
      post :import
    end
  end

  resources :product_receipts do
    member do
      get :accept
      put :mark_as_received
      get :accept_product
    end
    collection do
      get :add_product
    end
  end

  resources :product_transfer_receipts do
    member do
      get :accept
      put :mark_as_received
      get :accept_product
    end
    collection do
      get :add_product
    end
  end
  resources :member_types do
    collection do
      get :autocomplete_member_type_name
      post :import
    end
  end
  resources :catalogs do
    collection do
      get :autocomplete_catalog_name
      post :import
    end
  end
  resources :petty_cash_types do
    collection do
      get :autocomplete_petty_cash_type_name
      post :import
    end
  end
  resources :colours do
    collection do
      get :autocomplete_colour_name
      post :import
    end
  end
  resources :cashbacks do
    collection do
      #get :autocomplete_cashback_name
      post :import
    end
  end
  resources :member_levels do
    collection do
      get :autocomplete_member_level_description
      post :import
    end
  end
  resources :to_do_lists do
    collection do
      post :import
    end
  end
  resources :promotions do
    collection do
      get :search
      get :autocomplete_promotion_name
      get :add_prize_list
      get :add_promo_item_list
      get :search_product_manual
      get :search_in_modal
      get :get_product
    end
  end

  resources :branch_prices

  resources :stock_opnames do
    collection do
      get :get_quantity_data
      get :start_stock_opname_data
      get :end_stock_opname_data
      get :select_stock_opname_data
    end
  end

  resources :stock_opname_details do
    collection do
      post :import
    end
  end

  resources :members do
    collection do
      get :search
      get :discount
      post :create_member_discount
      post :import
      get '/edit_member_discount/:id' => 'members#edit_member_discount', as: :edit_member_discount
      put '/update_member_discount/:id' => 'members#update_member_discount', as: :update_member_discount
      delete '/delete_member_discount/:id' => 'members#delete_member_discount', as: :delete_member_discount
      put '/expired/:id' => 'members#expire', as: :expire
      get '/setting_point' => 'members#setting_point', as: :setting_point
      post 'create_setting_point' => 'members#create_setting_point', as: :create_setting_point
    end
  end

  resources :colours do
    collection do
      get :search
      get :autocomplete_colour_name
    end
  end

  resources :out_stocks do
    collection do
      get :search
      get :autocomplete_out_stock_name
    end
  end

  resources :min_stocks do
    collection do
      get :search
      get :autocomplete_min_stock_name
    end
  end

  resources :price_histories do
    collection do
      get :search
    end
  end

  resources :good_transfers do
    member do
      get :print_to_pdf
    end
    collection do
      get :search
      get :autocomplete_good_transfer_code
      get :get_product
      get :add_brand
      get :add_product
      get :get_last_number
    end
  end

  resources :departments do
    collection do
      get :search
      get :autocomplete_department_name
      get :departments_per_supplier
      post :import
      get :departments_list
    end
  end

  resources :brands do
    collection do
      get :search
      get :autocomplete_brand_name
      post :import
      get :brands_per_supplier
      get :generate_data_brand
    end
  end

  resources :suppliers do
    collection do
      get :get_number
      get :search
      get :autocomplete_supplier_name
      get :autocomplete_supplier_code
      post :import
      get :add_contact
      get :add_bank_account
    end
  end

  resources :sizes do
    collection do
      get :search
      get :autocomplete_size_name
      get :generate_details
      post :import
    end
  end

  resources :types do
    collection do
      get :search
      get :autocomplete_type_name
      get 'detail_sub_type/:id' => "types#detail_sub_type", as: :detail_sub_type
      get 'new_sub_type/:id' => "types#new_sub_type", as: :new_sub_type
    end
  end

  devise_for :users
  resources :users do
    collection do
  #     post :search
  #     get :search
      get :autocomplete_name
    end
  #   member do
  #     get :unsuspend
  #   end
  end
  resources :user_profiles do

  end

  resources :organizations do
    member do
      get :position_edit
    end
    collection do
      get :search
      get :posisision_data
      get :position_index
      post :position_index
      get :position_show
      get :position_new
      post :position_create
      delete :position_destroy
      patch :position_update
      put :position_update

    end
  end

   resources :positions

  resources :fingerprints do
    collection do
      get :search
    end
  end



  resources :companies do
    collection do
      get :get_city
    end
  end

  resources :roles

  resources :approvals

  resources :asset_assignments do
    collection do
      post :return
    end
  end

  resources :recruitments

  resources :visions, only: [:index, :show] do
    collection do
      post :setup
      get :visi_misi
    end
  end

  resources :misions, only: [:index, :show] do
    collection do
      post :setup
    end
  end

  resources :cultures, only: [:index, :show] do
    collection do
      post :setup
    end
  end


  resources :code_of_conducts, only: [:index, :show] do
    collection do
      post :setup
    end
  end

  resources :values, only: [:index, :show] do
    collection do
      post :setup
    end
  end

  resources :holidays

  resources :personal_datas

  resources :holiday_types do
    collection do
      put :update_holiday_type
      get :search
    end
  end

  resources :shifts

  resources :knowledges do
    collection do
    	get :autocomplete_name
      get :knowledge_new
      get :search
      get :knowledge_show
      get :knowledge_new
      post :knowledge_create
      delete :knowledge_destroy
      get :knowledge_edit
      patch :knowledge_update
      put :knowledge_update
      post :dropzone
      get :dropzone

    end
  end


  resources :blast_messages do
    collection do
      get :autocomplete_organization_name
      get :autocomplete_employee_name
    end
  end

  resources :components do
  collection do
      put :update_component
      post :import
    end
  end
  resources :selecteds

  resources :knowledges

  resources :knowledge_details

  resources :families do
    collection do
      put :update_family
    end
  end

  resources :employee_histories do
    collection do
      put :update_employee_histories
    end
  end

  resources :employee_working_datas do
    collection do
      put :update_employee_working_data
      post :import
    end
  end

  resources :salaries do
    collection do
      put :update_salary
      post :import
    end
  end

  resources :performances do
    collection do
      put :update_performance
    end
  end

  resources :employees do
    collection do
end
end

  resources :components

  resources :families do
    collection do
      put :update_family
    end
  end

  resources :position_details do
    collection do
      put :update_position_detail
      post :import
    end
  end

  resources :contracts do
    collection do
      put :update_contract
    end
  end

  resources :training_histories do
    collection do
      put :update_training_history
    end
  end

  resources :language_skills do
    collection do
      put :update_language_skill
    end
  end

  resources :skills do
    collection do
      put :update_skill
    end
  end

resources :violation_details do
    collection do
      put :update_violation_detail
    end
  end

  resources :salaries do
    collection do
      put :update_salary
    end
  end

  resources :member_levels

  namespace :api do
    resources :members, :only => [:create]
    resources :transactions, :only => [:create]
    resources :desktop_api, only: [:index] do
      collection do
        get :vouchers_list
        get :pos_machines_list
        get :voucher_details_list
        get :product_size_list
        get :vouchers_list
        get :prizes_list
        get :promo_items_list
        get :member_balance_mutations_list
        get :member_point_mutations_list
        get :cashback
        post :lock_member
        get :use_promo
        get :product_promo_discounts
        get :discount_histories
        get :product_discount
        get :member_levels
        get :users
        get :promotions_list
        get :edc_bank_account_list
        get :product_detail_list
        get :price_per_branch
        get :department_list
        get :product_stock
        get :size_details_list
        get :size_list
        get :m_class_list
        get :supplier_list
        get :product_list
        get :gift_list
        get :members
        get :voucher
        get :roles
        get :voucher_details
        post :transaction
        post :create_sod_eod
        post :update_sod_eod
        post :create_member
        post :create_session
        post :create_member_balance
        post :create_member_point
        post :create_goods_request
        post :create_goods_movement
        post :create_voucher
        post :voucher_to_used
        post :create_sales
        post :create_exchange_order
        post :create_refund_order
        post :sync_ptb
        post :active_and_unused_vouchers
        get :colours_list
        get :brands_list
        get :item_request_list
        post :process_employee
        get :get_employees
        get :warehouse_list
        get :goods_detail_list
        get :member_list
        get :bank_list
        get :goods_sizes_list
        get :unit_list
        get :product_list_new
        get :branch_list
      end
    end
    devise_for :users, path_prefix: 'api', controllers: {sessions: "api/sessions"}
  end

  resources :external_work_experiences do
    collection do
      put :update_external_work_experience
    end
  end

  resources :internal_work_experiences do
    collection do
      put :update_internal_work_experience
    end
  end

  resources :history_of_organizations do
    collection do
      put :update_history_of_organization
    end
  end

  resources :certifications do
    collection do
      put :update_certification
    end
  end

  resources :performances do
    collection do
      put :update_performance
    end
  end

  resources :po_histories

  resources :employees do
    collection do
      get :employee_working_datas
      get :new_employee_working_datas
      post :create_employee_working_datas
       get :employee_histories
      get :new_employee_histories
      post :create_employee_histories
      get :family_details
      get :new_family_details
      post :create_family_details
      get :new_personal_data
      post :create_personal_data
    end
  end

  resources :divisions

  resources :absences

  resources :appraisals do
    collection do
      get :get_value
    end
  end

  resources :leave_requests

  resources :overtime_requests

  resources :overtime_requests do
    collection do
      put :update_overtime_request
      post :import
    end
  end

  resources :interview_results do
    member do
      patch :update_status
      put :update_status
    end
  end

  resources :test_results do
    member do
      patch :update_status
      put :update_status
    end
  end


  resources :approval_levels do
    collection do
      get :autocomplete_employee_name
    end
  end

  resources :code_of_conducts, only: [:index] do
    collection do
      post :index
      post :setup
    end
  end
  resources :media_socials

  # post '/add_user' => "users#create"
  # put "/profiles" => "users#update_profile"
  # get "/profile" => "users#profile"

  root 'dashboards#index'
  get 'dashboards/line_chart'
  get 'dashboards/daily_sales'
  post 'dashboards/update_todolist'


resources :surveys do
    collection do
      post :filter
      get :filter

      post :get_view
      get :reload
      post :reorder
      get :question_list
      get "preview/:id" => "surveys#preview", as: :preview
      get :add_row
      get :remove_row
      get :question_detail
      get :question_page
      get :reset_session

      post :set_question
      get :edit_question
      get :add_question
      get "manage_question/:section" => "surveys#manage_question", as: :manage_question
      post "manage_question/:section" => "surveys#manage_question", as: :manage_question_post

      post :set_logical
      get :edit_logical
      get :add_logical
      get "manage_logical/:section" => "surveys#manage_logical", as: :manage_logical
      post "manage_logical/:section" => "surveys#manage_logical", as: :manage_logical_post

      post :set_page
      get :edit_page
      get :add_page
      get "manage_page/:section" => "surveys#manage_page", as: :manage_page
      post "manage_page/:section" => "surveys#manage_page", as: :manage_page_post
    end
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  resources :purchase_order_approvals do
    collection do
      post :approve
      post :generate_pdf
    end
  end

  resources :purchase_orders do
    collection do
      get :search
      get :get_purchase_request
      get :get_supplier
      get :autocomplete_purchase_order
      get :add_product_pr
      get :add_product
      get :get_size
      get :get_last_number
      get :po_per_supplier
    end
    member do
      put :approve
      get :print_to_pdf
      get :print_for_supplier
      get :continued
    end
  end

  resources :receivings do
    collection do
      get :get_purchase_order
      get :add_product
      get :add_product_po
      get :autocomplete_receiving_number
      get :get_last_number
      get :search_product
    end
    member do
      put :mark_as_inspected
      get :print_to_pdf
    end
  end

  resources :purchase_requests do
    collection do
      get :add_product
      get :get_product
      get :get_supplier
      get :get_last_number
      get :get_size
      get :search_product_manual
      get :search_in_modal
      get :autocomplete_purchase_request
      get :print_to_excel
    end
    member do
      get :print_to_pdf
    end
  end

  resources :purchase_transfers do
    collection do
      get :get_product
      get :get_pr
      get :get_size
      get :add_product_pr
      get :add_product
      get :get_last_number
      get :autocomplete_purchase_transfer
    end
    member do
      get :print_to_pdf
    end
  end

  resources :dibeliowners do
    collection do
      get :get_product
      get :get_pr
      get :get_size
      get :add_product_pr
      get :add_product
      get :get_last_number
      get :autocomplete_dibeliowner
    end
    member do
      get :print_to_pdf
    end
  end


  resources :inventory_requests
  resources :purchase_requisitions
  resources :disbursement_requests

  resources :disbursement_approvals do
    collection do
      post :approve
      post :generate_pdf
    end
  end

  resources :purchase_requisition_approvals do
    collection do
      post :approve
      post :generate_pdf
    end
  end

  resources :inventory_request_approvals do
    collection do
      post :approve
      post :generate_pdf
    end
  end

  resources :disbursement_realization_approvals do
    collection do
      post :approve
      post :generate_pdf
    end
  end

  get 'reports/store_stock_movement'
  get 'reports/return_all_branch'
  get 'reports/receiving'
  get 'reports/forecast'
  get 'reports/eod'
  get 'reports/stock'
  get 'reports/monthly_stock'
  get 'reports/sale'
  get 'reports/cashier'

  resources :returns_to_suppliers, except: [:destroy] do
    collection do
      get 'mark_as_delivered/:id' => 'returns_to_suppliers#mark_as_delivered', as: :mark_as_delivered
      post :add_by_barcode
      get :add_product
      get :get_product
      get :get_receiving
      get :add_product_receive
      get :search
      get :get_last_number
    end
    member do
      get :print_to_pdf
      get :print_for_supplier
    end
  end

  resources :return_to_ho_receipts, except: [:destroy] do
    member do
      get :accept
      put :mark_as_received
      get :accept_product
    end
  end

  resources :returns_to_hos, except: [:destroy] do
    collection do
      get :add_product_pt
      get :add_product
      post :add_by_barcode
      post :add_by_barcode_edit
      put 'mark_as_received/:id' => 'returns_to_head_offices#mark_as_received', as: :mark_as_received
      get 'receive/:id' => 'returns_to_head_offices#receive', as: :receive
      get 'cancel_return/:id' => 'returns_to_head_offices#cancel_return', as: :cancel_return
      get :add_item
      get :get_receiving
      get :search_product_manual
      get :get_product
      get :get_last_number
    end
    member do
      get :print_to_pdf
    end
  end

  resources :users do
    collection do
      post :login
      get :logout
      get :new_session
    end
  end
end
