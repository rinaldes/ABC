class ProductMutationHistory < ActiveRecord::Base
  belongs_to :product_detail
  belongs_to :product_mutation_detail
end
