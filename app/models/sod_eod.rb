class SodEod < ActiveRecord::Base
  serialize :cash

  belongs_to :office
  belongs_to :user
  has_many :cash_at_banks
  accepts_nested_attributes_for :cash_at_banks, allow_destroy: true


#  before_save :set_start_time, if: 'start_time.present?'
 # before_update :set_end_time, if: 'end_time.present?'

#  before_save :calculate_start_amount, if: 'start_time.present?'
#  before_update :calculate_end_amount, if: 'end_time.present?'

#  before_update :calculate_total_cash_sales, if: 'end_time.present?'
 # before_update :calculate_petty_cash, if: 'end_time.present?'
  #before_update :calculate_difference, if: 'end_time.present?'

  after_create :generate_session_number

  validates :office_id, :presence => { message: "Branch is required" }
  validates :sod_eod_date, :presence => true
#  validates :start_time, presence: { message: "Star time is required" }, on: :create
#  validates :user_id, presence: { message: "Cashier is required" }

  def set_start_time
    self.start_time = self.start_time.to_time
  end

  def set_end_time
    self.end_time = self.end_time.to_time
  end

  def calculate_start_amount
    self.start_amount  = 0
    start_cash = self.cash[:start]
    start_cash.each do |c|
      self.start_amount  += c.first.to_f * c.last.to_f
    end
  end

  def calculate_end_amount
    self.end_amount  = 0
    end_cash = self.cash[:end]
    end_cash.each do |c|
      self.end_amount  += c.first.to_f * c.last.to_f
    end
  end

  def calculate_total_cash_sales
    sales = Sale.where("user_id=? AND created_at between ? AND ?", User.current.id, start_time, end_time)
    self.total_cash_sales =  !sales.blank? ? sales.select("SUM(total_paid)") : 0
  end

  def self.get_total_cash_sales
  	calculate_total_cash_sales
  end

  def calculate_petty_cash
    self.petty_cash = (self.end_amount.to_f - self.total_cash_sales.to_f) - self.total_spending.to_f
  end

  def calculate_difference
    self.difference = self.actual_end_amount.to_f - self.petty_cash.to_f
  end

  def self.in_date(in_date)
    if in_date.present?
      where(sod_eod_date: in_date.to_date)
    else
      where(nil)
    end
  end

  def self.in_branch(in_branch)
    if in_branch.present?
      joins(:office).where("lower(offices.office_name) LIKE ?", "%#{in_branch}%")
    else
      where(nil)
    end
  end

  def has_started?
    self.start_time.present?
  end

  def has_ended?
    self.end_time.present?
  end

  def generate_session_number
    session = SodEod.where("office_id = ? AND sod_eod_date = ? AND id != ?", self.office_id, self.sod_eod_date, self.id).order('start_time DESC').count + 1
    self.update_attributes(:session => session)
  end

  def self.get_deposit(date, branch_id)
    date = date.blank? ? Time.now : (date["year"] + "-" + date["month"] + "-" + date["day"])
    sod_eods = SodEod.in_date(date)
    if branch_id.present?
      sod_eods = sod_eods.where("office_id = ?", branch_id)
    end

    return sod_eods
  end

  def self.get_variable_deposit(sod_eods)
    end_100k = sod_eods.sum(:end_100k)
    sum_end_100k = sod_eods.sum(:end_100k) * 100000
    end_50k = sod_eods.sum(:end_50k)
    sum_end_50k = sod_eods.sum(:end_50k) * 50000
    end_20k = sod_eods.sum(:end_20k)
    sum_end_20k = sod_eods.sum(:end_20k) * 20000
    end_10k = sod_eods.sum(:end_10k)
    sum_end_10k = sod_eods.sum(:end_10k) * 10000
    end_5k = sod_eods.sum(:end_5k)
    sum_end_5k = sod_eods.sum(:end_5k) * 5000
    end_2k = sod_eods.sum(:end_2k)
    sum_end_2k = sod_eods.sum(:end_2k) * 2000
    end_1k = sod_eods.sum(:end_1k)
    sum_end_1k = sod_eods.sum(:end_1k) * 1000
    end_500 = sod_eods.sum(:end_500)
    sum_end_500 = sod_eods.sum(:end_500) * 500
    end_200 = sod_eods.sum(:end_200)
    sum_end_200 = sod_eods.sum(:end_200) * 200
    end_100 = sod_eods.sum(:end_100)
    sum_end_100 = sod_eods.sum(:end_100) * 100
    end_50 = sod_eods.sum(:end_50)
    sum_end_50 = sod_eods.sum(:end_50) * 50
    total_deposit = sum_end_100k + sum_end_50k + sum_end_20k + sum_end_10k + sum_end_5k + sum_end_2k + sum_end_1k + sum_end_500 + sum_end_200 + sum_end_100 + sum_end_50
    hash_deposit = { "end_100k" => end_100k, "sum_end_100k" => sum_end_100k, "end_50k" => end_50k, "sum_end_50k" => sum_end_50k, "end_20k" => end_20k, "sum_end_20k" => sum_end_20k, "end_10k" => end_10k, "sum_end_10k" => sum_end_10k, "end_5k" => end_5k, "sum_end_5k" => sum_end_5k, "end_2k" => end_2k, "sum_end_2k" => sum_end_2k, "end_1k" => end_1k, "sum_end_1k" => sum_end_1k, "end_500" => end_500, "sum_end_500" => sum_end_500, "end_200" => end_200, "sum_end_200" => sum_end_200, "end_100" => end_100, "sum_end_100" => sum_end_100, "end_50" => end_50, "sum_end_50" => sum_end_50, "total_deposit" => total_deposit }
  end
end
