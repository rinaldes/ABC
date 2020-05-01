class FinanceReports::JournalMemosController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:destroy]
  before_filter :prepare_journal_memos, only: [:index, :export]
  before_filter :can_manage_journal_memo_report, only: [:index]

  add_crumb "Finance", '/'
  add_crumb("Journal Memo Report".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_journal_memos_path }
  add_crumb("List".html_safe, only: ["index"]) { |instance| instance.send :finance_reports_journal_memos_path }

  def index
    filename = "Journal Memo Report.xlsx"
    respond_to do |format|
      format.html
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end

  def export
    filename = "Journal Memo Report.xlsx"
    respond_to do |format|
      format.xlsx { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end

  def brands_per_supplier
    conditions = []
    conditions << "supplier_id = #{params[:supplier_id]}" if params[:supplier_id].present?
    @brands = Brand.where(conditions)
    respond_to do |format|
      format.js
    end
  end

  private
    def prepare_journal_memos
      date = (params[:year] + "-01-01").to_time if params[:year].present?
      @brands = Brand.all
      conditions = []
      conditions << "receivings.supplier_id = '#{params[:supplier_id]}'" if params[:supplier_id].present? && (params[:supplier_id] != 0 && params[:supplier_id] != '0')
      conditions << "date='#{params[:date]}'" if params[:date].present?
      conditions << "date BETWEEN '#{params[:year]}-#{sprintf('%02d', params[:month].to_i)}-01 00:00:00'
        AND '#{"#{params[:year]}-#{sprintf('%02d', params[:month].to_i)}-01".to_date.end_of_month.strftime('%Y-%m-%d')} 23:59:59'" if params[:month].present? && params[:year].present?
      @journal_memos = Receiving.where(conditions).get_journal_memos
    end

    def can_manage_journal_memo_report
      not_authorized unless current_user.can_manage_journal_memo_report?
    end
end
