require 'mechanize'
require 'csv'
require 'json'
require 'yaml'
require 'unf_ext'

require "scrapey/scrapey"
require "scrapey/constants"
require "scrapey/cache"
require "scrapey/database"
require "scrapey/multi"
require "scrapey/tee"

require 'addressable/uri'
 
class URI::Parser
  def split url
    a = Addressable::URI::parse url
    [a.scheme, a.userinfo, a.host, a.port, nil, a.path, nil, a.query, a.fragment]
  end
end


# don't do this stuff in rails:
unless defined? Rails
  Scrapey::init binding

  # default output file
  @output = File.join BASEDIR, 'output.csv'

  # read config file
  config_file = "#{BASEDIR}/config/config.yml"
  @config = File.exists?(config_file) ? YAML::load(File.open(config_file)) : {}

  init_db if @config['database']

  #$stderr = Scrapey::Tee.new(STDERR, File.open("#{BASEDIR}/errors.log", "w"))
end

if defined?(Ocra)
  puts "doing ocra stuff..."
  Mechanize.new.cookies
  HTTP::Cookie::Scanner.new ''
  if @config['database'] || @config['databases']
    puts "doing ocra db stuff..."
    ActiveRecord::Relation::PredicateBuilder.new rescue nil
    [
    'active_record',
    'active_record/schema',
    'active_record/connection_adapters/abstract/schema_definitions',
    @config['database'] ? @config['database']['adapter'] : 'mysql',
    'tzinfo',
    'active_support/all',
    'active_support/multibyte/chars'
    ].each{|lib| require lib}
  end
end

Dir.chdir BASEDIR
