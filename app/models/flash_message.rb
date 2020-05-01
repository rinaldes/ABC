class FlashMessage
  def self.partial_import_success line
    "Successfully imported until line #{line}. Failed imported  from line #{line+1}. Please recheck and reupload from line #{line+1}"
  end

  def self.recheck_csv
    "Import failed, please recheck CSV file"
  end
end
