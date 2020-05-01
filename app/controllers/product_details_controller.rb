class ProductDetailsController < ApplicationController
  def show
    @product_detail = ProductDetail.find(params[:id])
  end
end
