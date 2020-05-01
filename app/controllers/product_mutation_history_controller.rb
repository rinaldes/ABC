class ProductMutationHistoryController < ApplicationController
  def index
  	get_paginated_productmutationhistories
  	respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def get_paginated_productmutationhistories
  	if params[:product_detail_id].blank?
      @productmutationhistories = ProductMutationHistory.all.paginate(page: params[:page], per_page: 100) || []
    else
      @productmutationhistories = ProductMutationHistory.where("product_detail_id = ?", params[:product_detail_id]).order(:id).paginate(page: params[:page], per_page: 100) || []
    end
    @product = ProductDetail.find_by_id(params[:product_detail_id]).product_size.product rescue nil
    @office = ProductDetail.find_by_id(params[:product_detail_id]).warehouse rescue nil
  end
end