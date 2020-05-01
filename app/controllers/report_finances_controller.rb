class ReportFinancesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy, :check_new_order]

  def pembayaran_per_bulan
  	get_paginated_pembayaran_per_bulan
  end

  def search_pembayaran_per_bulan
    @group_by = params[:group_by]
    get_paginated_pembayaran_per_bulan
    respond_to do |format|
      format.js
    end
  end

  def print_to_pdf
    #@supplier = @purchase_order.supplier
    #@purchase_order_details = @purchase_order.purchase_order_details
    #html = render_to_string(:layout => "pdf_layout.html")
    #pdf = WickedPdf.new.pdf_from_string(html, :orientation => 'Portrait')
    #send_data(pdf,
    #  :filename    => "PO-#{@purchase_order.supplier.name}-#{@purchase_order.office.office_name} #{@purchase_order.number}.pdf",
    #  :disposition => 'attachment',
    #)
  end

  private
    def get_paginated_pembayaran_per_bulan
      conditions = []
      case @group_by
      when "Pembayaran by Giro"
        @reports = []
      when "Tunai dan Cash"
        @reports = []
      when "Laporan Rekapan Total"
        @reports = []
      else
        @reports = []
      end
    end
end