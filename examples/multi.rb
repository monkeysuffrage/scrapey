require 'scrapey'
require 'scrapey/multi'

fields 'url', 'title'

def scrape url, response
  doc = Nokogiri::HTML response
  @items << {'url' => url, 'title' => doc.at('title').text}
end

@items = []
multi_get ['http://www.yahoo.com/', 'http://www.google.com.', 'http://www.bing.com/'], 3, :scrape
@items.each{|item| save item}
