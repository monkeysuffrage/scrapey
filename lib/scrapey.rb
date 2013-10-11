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

# don't do this stuff in rails:
unless defined? Rails
  Scrapey::init binding

  # default output file
  @output = File.join BASEDIR, 'output.csv'

  # read config file
  config_file = "#{BASEDIR}/config/config.yml"
  @config = File.exists?(config_file) ? YAML::load(File.open(config_file)) : {}

  init_db if @config['database']

  $stderr = Scrapey::Tee.new(STDERR, File.open("#{BASEDIR}/errors.log", "w"))
end

