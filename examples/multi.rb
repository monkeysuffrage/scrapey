require 'scrapey'

fields 'url', 'title'

def scrape url, response
  doc = Nokogiri::HTML response
  save({'url' => url, 'title' => doc.title})
end

multi_get ['http://www.yahoo.com/', 'http://www.google.com.', 'http://www.bing.com/'], :threads => 3, :on_success => :scrape
