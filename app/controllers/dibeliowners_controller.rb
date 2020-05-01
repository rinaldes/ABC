class DibeliownersController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :get_paginated_dibeliowners, only: [:index, :destroy]
  autocomplete :dibeliowner, :number
  before_filter :can_view_product_transfer, only: [:index, :show]
  before_filter :can_manage_product_transfer, only: [:new, :create, :edit, :update, :destroy]

  def index
  end

  def new
    time_now = Time.now
    @dibeliowner = Dibeliowner.new
    load_master
  end

  def show
    @good_transfer = Dibeliowner.find params[:id]
    @list_product = ProductDetail
    .where("warehouse_id=#{(current_user.branch.id rescue Branch.first.id)} AND product_size_id IN (SELECT product_size_id FROM product_mutation_details WHERE product_mutation_id=#{@good_transfer.id})")
    .joins(product_size: [:product]).group_by{|pd|pd.product_size.product_id}
  end

  def print_to_pdf
    @good_transfer = Dibeliowner.find params[:id]
    @supplier = @good_transfer.supplier
    @list_product = ProductDetail.where("warehouse_id=#{(current_user.branch.id rescue Branch.first.id)} AND product_size_id IN (SELECT product_size_id FROM product_mutation_details WHERE product_mutation_id=#{@good_transfer.id})").joins(product_size: [:product]).group_by{|pd|pd.product_size.product_id}
    html = render_to_string(:layout => "pdf_layout.html") 
    pdf = WickedPdf.new.pdf_from_string(html, :orientation => 'Landscape') 
    send_data(pdf, 
      :filename    => "Dibeli Owner #{@good_transfer.code}.pdf", 
      :disposition => 'attachment',
    ) 
  end

  #only can be done by HO person
  def create
    details = params[:dibeliowner][:dibeliowner_details_attributes].values
    @dibeliowner = Dibeliowner.new(dibeliowner_params.merge(status: ProductMutation::PENDING, code: (Dibeliowner.last.id.to_i+1 rescue 1),
      receiving_id: (Receiving.find_by_number(params[:pr_name]).id rescue nil),
      total_price: details.map{|mutation|(ProductSize.find_by_id(mutation["product_size_id"]).product.cost_of_products.to_f)*mutation["quantity"].to_i}.sum,
      total_value: details.map{|mutation|(ProductSize.find_by_id(mutation["product_size_id"]).product.selling_price.to_f)*mutation["quantity"].to_i}.sum, user_id: current_user.id,
      total_quantity: details.map{|mutation|mutation["quantity"].to_i}.sum
    ))
    respond_to do |format|
      if @dibeliowner.save
        hash = {}
        params[:dibeliowner][:dibeliowner_details_attributes].values.map{|a|
          hash = hash.merge(a.values[1] => a.values[0])
        }
        pr = PurchaseRequest.find_by_number(params[:pr_name])
        if pr.present?
          detail = pr.purchase_request_details
          pr_closed = false
          ProductMutationDetail.where("product_mutation_id IN (SELECT transfer_product_id FROM pr_transfer_products WHERE purchase_request_id=?) AND quantity>0", pr.id)
            .group_by(&:product_size_id).each{|b|
            if detail.find_by_product_size_id(b[0]).approved_qty >= b[1].map(&:quantity).compact.sum+hash["#{b[0]}"].to_i
              pr_closed = false
              break
            end
            pr_closed = true
          }
          rc = Receiving.find_by_purchase_order_id(pr.purchase_order_id)
          PrTransferProduct.create purchase_request_id: pr.id, transfer_product_id: @dibeliowner.id, receiving_id: (rc.id rescue nil)
          pr.update_attributes(status: pr_closed ? 'CLOSED' : PurchaseRequest::TRANSFER_ON_PROGRESS)
        else
          rc = Receiving.where("distributed_qty<received_qty").limit(1).first
          PrTransferProduct.create transfer_product_id: @dibeliowner.id, receiving_id: (rc.id rescue nil)
        end
        rc.update_attributes(distributed_qty: rc.distributed_qty+@dibeliowner.total_quantity)
        flash[:notice] = t(:successfully_created)
      else
        flash[:error] = @dibeliowner.errors.full_messages.join('<br/>')
      end
      format.js
    end
  end

  def add_product_pr
    @purchase_request = PurchaseRequest.find_by_number(params[:number])
    @purchase_request_details = @purchase_request.purchase_request_details
    @supplier = @purchase_request.purchase_request_details.first.product_size.product.brand.supplier rescue nil
    @received_products = Dibeliowner.where("id IN (SELECT transfer_product_id FROM pr_transfer_products WHERE purchase_request_id=?)", @purchase_request.id)
    @quantities = {}
    respond_to do |format|
      format.js
    end
  end

  def update
    @transfer = Dibeliowner.find_by_id(params[:id])
    if @transfer.update_attributes(dibeliowner_params)
      products = params[:good_list].split(',')
      not_in = @transfer.dibeliowner_details.map{|x| x.product_id} - products
      @dibeliowner.dibeliowner_details.where(:product_id => not_id).destroy_all
      products.each do |product|
        detail = DibeliownerDetail.find_by_pruchase_transfer_id_and_product_id(@transfer.id, product)
        if detail.blank?
          @transfer.dibeliowner_details.build(:product_id => product.to_i).save
        end
      end
      flash[:notice] = 'Purchase Transfer berhasil diupdate'
      redirect_to dibeliowners_path
    else
      flash[:error] = @good_transfer.errors.full_messages
      render "edit"
    end
  end


  def autocomplete_dibeliowner
    hash = []
    conditions = ["LOWER(code) LIKE LOWER('%#{params[:term]}%')"]
    conditions << "origin_warehouse_id=#{params[:origin_warehouse_id]}" if params[:origin_warehouse_id].present?
    conditions << "destination_warehouse_id=#{params[:destination_warehouse_id]}" if params[:destination_warehouse_id].present?
    conditions << "supplier_id=#{params[:supplier_id]}" if params[:supplier_id].present?
    conditions << "code NOT IN (#{params[:present_transfer]})" if params[:present_transfer].present?
    pt = Dibeliowner.where(conditions.join(' AND ')).limit(11).order('code')
    pt.collect do |p|
      hash << {id: p.id, label: p.code, value: p.code, date: p.created_at.strftime('%Y-%m-%d'), pr_note: p.note, origin_warehouse: p.origin_warehouse.office_name,
        destination_warehouse: p.destination_warehouse.office_name}
    end
    render json: hash
  end

  def get_last_number
    render json: {
      number: (('%07d' % (((Dibeliowner.where("supplier_id=#{params[:supplier_id]} AND extract(YEAR FROM mutation_date)=#{Time.now.year}").order("id DESC").limit(1)[0].number.last.to_i rescue 0) +1))))
    }
  end

  def destroy
    @transfer = Dibeliowner.find_by_id(params[:id])
    respond_to do |format|
      if @transfer.destroy
        flash.now[:notice] = "Member berhasil dihapus"
      else
        flash.now[:error] = @transfer.errors.full_messages
      end
      format.js
    end
  end

  def edit
    @dibeliowner = Dibeliowner.find_by_id(params[:id])
    @supplier = @dibeliowner.supplier
    load_master
  end

  def load_master
    # @departments = MClass.where("parent_id IS NULL").select("name, id").order("name").map{|department|[department.name, department.id]}
    @prs = PurchaseRequest.select("number, id").limit(7).order("number").map{|purchase_request|[purchase_request.number, purchase_request.id]}
    @products = Product.select("barcode, id").limit(7).order("barcode").map{|product|[product.barcode, product.id]}
  end

  def get_product
    @product = Product.find_by_barcode(params[:barcode])
    @supplier = @product.brand.supplier
    @list_product = ProductDetail.where("warehouse_id=#{(params[:origin_warehouse_id])} AND products.id=#{@product.id}").joins(product_size: [:product]).sort_by{|pd|
      pd.product_size.size_detail.size_number.to_i
    }
    @list_product_in_branch = ProductDetail.where("warehouse_id=#{(params[:destination_warehouse_id])} AND products.id=#{@product.id}").joins(product_size: [:product])
    respond_to do |format|
      format.js
    end
  end

  def get_pr
    @pr = PurchaseRequest.find_by_number(params[:number])
    respond_to do |format|
      format.js
    end
  end

  def add_product
    @product = Product.find(params[:id])
    receiving = Receiving.find_by_number(params[:receiving_id]) rescue nil
    @list_product = ProductDetail.where("warehouse_id=#{(receiving.head_office_id)} AND products.id=#{@product.id}").joins(product_size: [:product]).sort_by{|pd|
      pd.product_size.size_detail.size_number.to_i
    }
    respond_to do |format|
      format.js
    end
  end

  def search_product_manual
    @products = Product.all
  end

  private
    def dibeliowner_params
      params.require(:dibeliowner).permit(
        :origin_warehouse_id, :status, :no_surat_jalan, :note, dibeliowner_details_attributes: [:quantity, :product_size_id]
      )
    end

    def get_paginated_dibeliowners
      conditions = []
      params[:search].each{|param|
        conditions << "LOWER(#{param[0]}) LIKE LOWER('%#{param[1]}%')" if param[1].present?
      } if params[:search].present?
      @dibeliowners = Dibeliowner.where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' ')).paginate(page: params[:page], per_page: 10) || []
    end

    def can_view_product_transfer
      not_authorized unless current_user.can_view_product_transfer?
    end

    def can_manage_product_transfer
      not_authorized unless current_user.can_manage_product_transfer?
    end
end
