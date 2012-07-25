require 'mechanize'
require 'csv'
require 'json'
require 'yaml'

require "scrapey/version"
require "scrapey/scrapey"
require "scrapey/cache"
require "scrapey/database"

include Scrapey

# some defaults that I like
@agent ||= Mechanize.new{|a| a.history.max_size = 10}
@agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'

# default output file
@output = Time.now.strftime("#{BASEDIR}/Output/output_%Y_%m_%d_%H_%M_%S.csv")

# read config file
config_file = "#{BASEDIR}/config/config.yml"
@config = File.exists?(config_file) ? YAML::load(File.open(config_file)) : {}

if @config['database']
  ['active_record', @config['database']['adapter'], 'tzinfo', 'active_support/all'].each{|lib| require lib}
	ActiveRecord::Base.establish_connection(@config['database']) 
end

