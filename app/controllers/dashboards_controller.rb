class DashboardsController < ApplicationController
  # before_action :get_blast_messages

  def daily_sales
    @departments = Department.where("parent_id IS NULL")
    departments = []
    @departments.each{|department|
      qty = SalesDetail.where("department_id=#{department.id} AND sales_details.created_at BETWEEN '#{Time.now.strftime('%Y-%m-%d 00:00:00')}' AND '#{Time.now.strftime('%Y-%m-%d 23:59:59')}'")
        .joins(product_size: :product).map(&:quantity).compact.sum
      if qty>0
        departments << {
          name: department.name,
          data: [qty]
        }
      end
    }
    render json: {departments: @departments.map(&:name), values: departments}
  end

  def line_chart
    result = []
    year = Time.now.year
    if params[:text] == 'Amount'
      Branch.all.each{|branch|
        trans_per_hour = []
        1.upto(23).each{|hour|
          trans_per_hour << Sale.where("created_at BETWEEN '#{Time.now.strftime('%Y-%m-%d 00:00:00')}' AND '#{Time.now.strftime("%Y-%m-%d #{hour}:00:00")}' AND store_id=#{branch.id}")
            .map(&:total_price).sum
        }
        result.push({name: branch.description, data: trans_per_hour})
      }
    else
      Branch.all.each{|branch|
        trans_per_hour = []
        1.upto(23).each{|hour|
          trans_per_hour << Sale.where("created_at BETWEEN '#{Time.now.strftime('%Y-%m-%d 00:00:00')}' AND '#{Time.now.strftime("%Y-%m-%d #{hour}:00:00")}' AND store_id=#{branch.id}")
            .map(&:total_quantity).sum
        }
        result.push({name: branch.description, data: trans_per_hour})
      }
    end
    render json: {line_chart: result}
  end

  def index
    @branches = Branch.all
    conditions = ["to_char(sales.created_at, 'YYYY-MM-DD')='#{Time.now.strftime('%Y-%m-%d')}'"]
    conditions << "store_id=#{@current_user.branch_id}" if @current_user.branch_id.present?
    @today_sales = SalesDetail.joins(:sale).where(conditions.join(' AND ')).select("SUM(sales_details.total_price) AS sum_all")[0].sum_all.to_f
    render file: "#{Rails.root.to_s}/app/views/dashboards/temp.html.erb"
  end

  def update_todolist
    if ToDoList.update(params["id"], :date => params["date"], :end_at => params["end_at"])
      render :json => { status: true }
    else
      render :json => { status: false }
    end
  end
end
