class AddHppToPmd < ActiveRecord::Migration
  def change
    add_column :product_mutation_details, :hpp, :float
  end
end
