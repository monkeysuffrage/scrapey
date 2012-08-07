require 'scrapey'
require 'scrapey/multi'

fields 'url', 'title'

def scrape url, response, header
  doc = Nokogiri::HTML response
  save({'url' => url, 'title' => doc.at('title').text})
  puts "scraped #{url}."
end

options = {
  :threads => 3,
  :callback => :scrape,
  :proxy => {:host => 'localhost', :port => 8888},
  :head => {
    "Accept" => "*/*",
    #"User-Agent" => "Scrapey #{Scrapey::VERSION}",
    "Keep-alive" => "true"
  }
}

multi_get ['http://www.yahoo.com/', 'http://www.google.com/', 'http://www.bing.com/'], options

puts "this happens after all callbacks."