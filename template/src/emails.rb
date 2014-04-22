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
=end

def post url, body
  page = @agent.post url, body
  JSON.parse(page.body).each{|k, v|}
  raise 'x' unless page.body
  page
rescue Exception => e
  print '!'
  sleep 10
  return post url, body
end

@agent.open_timeout = @agent.read_timeout = 10000

tables = ActiveRecord::Base.connection.tables

tables.each do |table|
  puts table
  tables table.camelize
  klass = table.camelize.constantize
  return unless klass.column_names.include?('website')

  klass.where("website is not null and email is null").find_in_batches(:batch_size => 10) do |group|
    page = post('http://www.pay4data.com/lookup/email_for_url', {urls: group.map(&:website).compact}.to_json)
    JSON.parse(page.body).each do |k, v|
      group.find{|r| r['website'] == k}.update_attributes(:email => v)
      puts k
    end
  end
end

