module Scrapey
  BASEDIR = File.expand_path(File.dirname($0)).gsub(/\/src$/,'')
  ENV['SSL_FILE'] = "#{Gem.dir}/gems/scrapey-#{Scrapey::VERSION}/ssl/cacert.pem"
end