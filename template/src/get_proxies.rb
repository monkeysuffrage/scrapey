require 'scrapey'
require 'pry'
require 'syck'
require "#{BASEDIR}/src/proxy.rb"


YAML::ENGINE.yamler='syck'

#proxies = Proxy::get_proxies :proxy_list
proxies = Proxy::get_proxies :all

@config['proxies'] = proxies.uniq
File.open("#{BASEDIR}/config/config.yml", 'w') { |f| YAML.dump(@config, f) }

