require 'scrapey'
require 'scrapey/multi'

fields 'url', 'status'

def scrape url, response, header
  save({'url' => url, 'status' => header.status})
end

multi_head ['http://www.yahoo.com/', 'http://www.google.com.', 'http://www.bing.com/', 'http://www.bing.com/404.html'], :threads => 4, :callback => :scrape
