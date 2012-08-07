require 'mechanize'
require 'csv'
require 'json'
require 'yaml'

require "scrapey/scrapey"
require "scrapey/constants"
require "scrapey/cache"
require "scrapey/database"

include Scrapey

# some defaults that I like
@agent ||= Mechanize.new{|a| a.history.max_size = 10}
@agent.user_agent = "Scrapey v#{Scrapey::VERSION} - #{Scrapey::URL}"

# default output file
@output = 'output.csv'

# read config file
config_file = "#{BASEDIR}/config/config.yml"
@config = File.exists?(config_file) ? YAML::load(File.open(config_file)) : {}

if @config['database']
  ['active_record', @config['database']['adapter'], 'tzinfo', 'active_support/all'].each{|lib| require lib}
	ActiveRecord::Base.establish_connection(@config['database']) 
end
