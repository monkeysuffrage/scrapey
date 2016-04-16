require 'scrapey'
require 'chronic'
require 'pry'

# sample customizations...
# @agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
# @output = Time.now.strftime("#{BASEDIR}/Output/output_%Y_%m_%d_%H_%M_%S.csv")

def guess_type column
  case column
    when /RaceId/i then 'integer'
    when /date/i then 'datetime'
    when /is_/i then 'boolean'
    when /descr/i then 'text'
    when /price/i then 'float'
    else 'string'
  end
end

def new_table name, columns

  ActiveRecord::Schema.define do
    create_table name, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      columns.each do |column|
        type = guess_type column
        t.send type, column
      end

=begin
      t.string   "string_field"
      t.text     "text_field"
      t.integer  "number_field"
      t.boolean  "boolean_field"
      t.float    "float_field"
      t.date     "created_at"
      t.datetime "created_on"
=end
    end
  end

end

def map row
  item = {}
  row.headers.each do |k|
    v = row[k]
    item[k] = case guess_type(k)
      when /date/ then Chronic.parse(v)
      when 'boolean' then v && v != 0
      else v
    end
  end
  item
end

Dir.glob('input/*.csv').each do |fn|
  @table = nil
  table_name = fn[/\/(.*)\.csv/, 1].gsub(/\W+/,'_')
  puts table_name

  CSV.foreach(fn, :headers => true, :header_converters => lambda{|h| h.downcase.gsub(/\W+/, '_')}) do |row|

    if !@table
      new_table table_name, row.headers
      tables table_name.singularize.camelize
      @table = table_name.singularize.camelize.constantize
    end

    data = map row
    #binding.pry

    @table.new(data).save

    print '.'
  end
end

