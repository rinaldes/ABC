require 'rufus-scheduler'
require 'active_support/core_ext'

# Schedule configuration
schedule = '00 07 * * *' # 07:00 every_date every_month every_day
day_length = 1.day # synchronize record up to 1 day before


scheduler = Rufus::Scheduler.new
=begin
scheduler.every '1m' do
`curl http://128.199.70.104/index.php?route=api/cron/get_categories`
`curl http://128.199.70.104/index.php?route=api/cron/get_brand`
`curl http://128.199.70.104/index.php?route=api/cron/get_colour`
`curl http://128.199.70.104/index.php?route=api/cron/get_size`
`curl http://128.199.70.104/index.php?route=api/cron/get_products`

`curl http://128.199.70.104/index.php?route=api/cron/post_transaction`
end
=end

# Branch configuration
pusat = {
  "database_name" => 'abc_development',
  "username" => 'dev',
  "password" => 'admin',
  "addrhost" => '127.0.0.1',
  "port" => 5432
}

branches = [
  {
    "database_name" => 'abc_development2',
    "username" => 'dev',
    "password" => 'admin',
    "addrhost" => '127.0.0.1',
    "port" => 5432
  },

  # Add another branch information here
  # {
  #   "database_name" => 'abc_development',
  #   "username" => 'dev',
  #   "password" => 'admin',
  #   "addrhost" => '127.0.0.1',
  #   "port" => 5432
  # }
]
=begin
scheduler = Rufus::Scheduler::singleton
scheduler.cron schedule do
  sync_pusat = DatabaseSync.new(pusat["database_name"], pusat["username"],
                             pusat["password"], pusat["addrhost"], pusat["port"])
  sync_pusat.export('/tmp/export-pusat.csv', sync_pusat.all_table, (Time.new - day_length).strftime('%Y-%m-%d'))

  branches.each_with_index do |branch, i|
    sync_branch = DatabaseSync.new(branch["database_name"], branch["username"],
                                   branch["password"], branch["addrhost"], branch["port"])
    sync_branch.import("/tmp/export-pusat.csv")

    table = ['sales', 'sales_details', 'product_mutation_histories', 'product_details']
    sync_branch.export("/tmp/export-branch-#{i}.csv", table, (Time.new - day_length).strftime('%Y-%m-%d'))
    sync_pusat.import("/tmp/export-branch-#{i}.csv")
  end
end
=end
