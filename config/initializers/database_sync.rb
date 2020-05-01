require 'pg'
require 'csv'

class DatabaseSync
  def initialize(dbname, user, password, hostaddr, port)
    @conn = PG::connect(dbname: dbname,
                        user: user,
                        password: password,
                        hostaddr: hostaddr,
                        port: port)
  end

  def export_sub(csv, update_last, table_name)
    deco = PG::TextDecoder::CopyRow.new
    @conn.copy_data "COPY (SELECT * FROM #{table_name} WHERE updated_at >= '#{update_last}') TO STDOUT", deco do
      while row = @conn.get_copy_data
        csv << [table_name] + row
      end
    end
  end

  def export(file, tables, update_last)
    CSV.open(file, 'w') do |csv|
      tables.each do |table|
        next if !test_update_column(table)
        export_sub(csv, update_last, table)
      end
    end
  end

  def import_sub(table, data)
    query = """CREATE TEMPORARY TABLE import_#{table} AS SELECT * FROM #{table} LIMIT 0;
               COPY import_#{table} FROM STDIN;
               BEGIN TRANSACTION;
               DELETE from #{table}
               WHERE id IN (SELECT id FROM import_#{table});
               INSERT INTO #{table} SELECT * FROM import_#{table};
               COMMIT TRANSACTION;"""

    enco = PG::TextEncoder::CopyRow.new
    @conn.copy_data query, enco do
      data.each do |row|
        @conn.put_copy_data row[0]
      end
    end
  end

  def import(file)
    table = Hash.new
    CSV.foreach(file) do |csv|
      if !table.has_key?(csv[0])
        table[csv[0]] = Array.new
      end

      table[csv[0]] << [csv[1..-1]]
    end

    table.each do |key, arr|
      import_sub(key, arr)
    end
  end

  def test_update_column(table)
    query = """SELECT column_name
               FROM information_schema.columns
               WHERE table_name='#{table}' and column_name='updated_at';"""
    return !@conn.exec(query).num_tuples.zero?
  end

  def all_table
    tables = Array.new
    query = """SELECT table_name
               FROM information_schema.tables
               WHERE table_schema='public' AND table_type='BASE TABLE'"""
    @conn.exec(query).each do |result|
      result.each do |row|
        tables << row[1]
      end
    end

    return tables
  end
end
