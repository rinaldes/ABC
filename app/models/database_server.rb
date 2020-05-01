class DatabaseServer < ActiveRecord::Base
  self.abstract_class = true
  self.establish_connection(
    :adapter  => 'postgresql',
    :database => 'abc_production4',
    :host     => '25.21.210.70',
    :username => 'postgres',
    :password => 'nuansabaru'
  )

  def self.sync_colour
    self.table_name = "colours"
    last_sync = LastUpdate.last.sync_date rescue "01/01/0001 00:00:00"
    DatabaseServer.where("updated_at > ?", last_sync).each do |sy|
      data_local = Colour.find_by_code(sy.code)
      if data_local.present?
        data_local.update_attributes(name: sy.name)
      else
        Colour.create sy.attributes
      end
    end
    LastUpdate.create(sync_date: DateTime.now())
  end
end