class CashOut < ActiveRecord::Base
  mount_uploader :receipt, PettyCashUploader
  belongs_to :petty_cash
  validates :cash_out_type, presence: true

  # before_save :set_time
  # after_save :customize_detail

  # def set_time
  #   self.time = self.time.to_time
  # end

  # def customize_detail
  #   pcd = PettyCashDetail.where(petty_cash_id: petty_cash_id, date: ).first_or_create
  #   pcd_tobe_updated = self.cash_out_type == 'CASH IN' ? {cash_in: pcd.cash_in.to_f+self.amount} : {cash_out: pcd.cash_out.to_f+self.amount}
  #   pcd.update_attributes(pcd_tobe_updated)
  # end

  def self.get_report
    self.where("LOWER(cash_out_type) != ?", "cash in").order('created_at ASC')
  end

  def set_time
    self.time = self.time.to_datetime
  end

  def customize_detail
    pcd = PettyCashDetail.where(date: Time.now.strftime('%Y-%m-%d')).first_or_create
    pcd_tobe_updated = self.cash_out_type == 'CASH IN' ? {cash_in: pcd.cash_in.to_f+self.amount} : {cash_out: pcd.cash_out.to_f+self.amount}
    pcd.update_attributes(pcd_tobe_updated)
  end

  def self.get_report
    self.where("LOWER(cash_out_type) != ?", "cash in").order('created_at ASC')
  end

  def self.get_outcome(date, branch_id)
    date = date.blank? ? Time.now.to_date : (date["year"] + "-" + date["month"] + "-" + date["day"]).to_date
    cash_outs = CashOut.joins(:petty_cash).where("cash_out_type != ? AND DATE(time) = ?", 'CASH IN', date)
    if branch_id.present?
      cash_outs = cash_outs.where("petty_cashes.office_id = ?", branch_id)
    end

    return cash_outs
  end

  def self.get_variable_outcome(cash_outs)
    mandiri = 0
    bni = 0
    bca = 0
    saldo_btp_income = 0
    outcome_cash = cash_outs.sum(:amount)
    hash_outcome = { "mandiri" => mandiri, "bni" => bni, "bca" => bca, "saldo_btp_income" => saldo_btp_income, "outcome_cash" => outcome_cash }
  end
end
