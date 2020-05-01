class RenameParentIdDibeliowner < ActiveRecord::Migration
  def change
    rename_column :dibeliowner_details, :purchase_transfer_id, :dibeliowner_id
  end
end
