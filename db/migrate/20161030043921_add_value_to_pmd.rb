class AddValueToPmd < ActiveRecord::Migration
  def change
    add_column :product_mutation_details, :value, :float
  end
end
