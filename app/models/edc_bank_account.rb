class EdcBankAccount < ActiveRecord::Base
  belongs_to :sale, foreign_key: :sales_id
end