require 'mechanize'
require 'csv'
require 'json'
require 'yaml'

require "scrapey/scrapey"
require "scrapey/constants"
require "scrapey/cache"
require "scrapey/database"
require "scrapey/multi"
require "scrapey/tee"

include Scrapey

# some defaults that I like
@agent ||= Mechanize.new{|a| a.history.max_size = 10}
@agent.user_agent = "Scrapey v#{Scrapey::VERSION} - #{Scrapey::URL}"
@agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
# default output file
@output = 'output.csv'

# read config file
config_file = "#{BASEDIR}/config/config.yml"
@config = File.exists?(config_file) ? YAML::load(File.open(config_file)) : {}

init_db if @config['database']

$stderr = Scrapey::Tee.new(STDERR, File.open("#{BASEDIR}/errors.log", "a"))