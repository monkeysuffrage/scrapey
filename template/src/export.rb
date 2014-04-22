require 'aws-sdk'
require 'scrapey'
require 'pry'

=begin
@config = {
  'category' => 'businesses',
  'dataset_name' => 'brazilian_companies',
  'database' => {
    'adapter' => 'mysql',
    'database' => 'stefan',
    'username' => 'root',
    'password' => '12345',
    'host' => 'localhost',
    'encoding' => 'utf8'
  }
}



  CSV.open("#{BASEDIR}/#{table}.csv", 'w') do |csv|
    csv << fields
    klass.where(:found => true).find_each do |row|
      csv << fields.map{|f| row[f]}
    end
  end

=end



def new_csv filename
  File.open(filename, 'w') do |file|
    file << 0xEF.chr + 0xBB.chr + 0xBF.chr
  end
  CSV.open(filename, 'a') do |csv|
    yield csv
  end
end

unless @config['dataset_name'] && @config['category']
  puts 'Please fill out dataset_name and category in config.yml to continue'
  exit
end
init_db
@tables = ActiveRecord::Base.connection.tables

all_fields = []

@tables.each do |table|
  puts table
  tables table.camelize
  klass = table.camelize.constantize

  all_fields << klass.column_names
  fields = klass.column_names - ['id', 'updated_at', 'created_at', 'updated_on', 'created_on']

  new_csv("#{BASEDIR}/#{table}.csv") do |csv|
    csv << fields
    klass.all.find_each do |row|
      csv << fields.map{|f| row[f]}
    end
  end

  new_csv("#{BASEDIR}/#{table}_sample.csv") do |csv|
    csv << fields
    klass.order(:id).order('rand()').limit(50).each do |row|
      csv << fields.map{|f| row[f]}
    end
  end

end

if @tables.length == 0
  table = @tables.first
  `gzip -f #{BASEDIR}/#{table}_sample.csv`
  `gzip -f #{BASEDIR}/#{table}.csv`
  csv_name = "#{table}.csv.gz"
  sample_name = "#{table}_sample.csv.gz"

  csv_name = "#{@config['dataset_name']}.csv.gz"
  `mv #{BASEDIR}/#{table}.csv.gz #{csv_name}`
  sample_name = "#{@config['dataset_name']}_sample.csv.gz"
  `mv #{BASEDIR}/#{table}_sample.csv.gz #{sample_name}`

else
  csv_name = "#{@config['dataset_name']}.csv.tar.gz"
  sample_name = "#{@config['dataset_name']}.sample.tar.gz"
  sample_sql = "#{@config['dataset_name']}_sample.sql"

  cmd = "tar -czf #{csv_name} " + @tables.map{|x| x + '.csv'}.join(' ')
  `#{cmd}`
  File.open(sample_sql, 'w') do |f|
    f << `"C:\\Program Files\\MySQL\\MySQL Server 5.6\\bin\\mysqldump.exe" -uroot -p12345 --where="true limit 100" #{@config['database']['database']}`
  end
  cmd = "tar -czf #{sample_name} #{sample_sql} " + @tables.map{|x| x + '_sample.csv'}.join(' ')
  `#{cmd}`
end

# --where="true limit 100"
File.open("#{@config['dataset_name']}.sql", 'w') do |f|  
  f << `"C:\\Program Files\\MySQL\\MySQL Server 5.6\\bin\\mysqldump.exe" -uroot -p12345 #{@config['database']['database']}`
end
`gzip -f #{@config['dataset_name']}.sql`
sql_name = "#{@config['dataset_name']}.sql.gz"

s3 = AWS::S3.new :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'], :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
bucket = s3.buckets['pay4data']

sample_object = bucket.objects["#{@config['category']}/#{sample_name}"].write :file => sample_name, :content_type => 'application/gzip', :acl => :public_read
csv_object    = bucket.objects["#{@config['category']}/#{csv_name}"].write :file => csv_name, :content_type => 'application/gzip'
sql_object    = bucket.objects["#{@config['category']}/#{sql_name}"].write :file => sql_name, :content_type => 'application/gzip'

sql = <<EOF
insert into datasets(sample_url, csv_url, sql_url, last_crawled, fields) values(
'#{sample_object.public_url.to_s}',
'#{csv_object.public_url.to_s}',
'#{sql_object.public_url.to_s}',
now(),
'#{fields.map{|t| (t - ['id', 'updated_at', 'created_at', 'updated_on', 'created_on']).join ', '}.join ", "}'
);

update datasets set category_id=5, name='', description='', price='', button_html='' where id=


mysqldump pay4data datasets categories | mysql2 pay4data


EOF

puts sql


