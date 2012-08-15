require 'scrapey'
require 'scrapey/multi'

fields 'url', 'title'

def scrape url, response, header
  doc = Nokogiri::HTML response
  save({'url' => url, 'title' => doc.at('title').text})
end

multi_get ['http://www.yahoo.com/', 'http://www.google.com.', 'http://www.bing.com/'], :threads => 3, :on_success => :scrape
