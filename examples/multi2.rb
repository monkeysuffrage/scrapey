require 'scrapey'
require 'scrapey/multi'

fields 'url', 'title'

def scrape url, response, header
  doc = Nokogiri::HTML response
  save({'url' => url, 'title' => doc.at('title').text})
  puts "scraped #{url}."
end

def on_error url, e
  puts "oops, #{url} gave the following error: #{e}..."
end

options = {
  :threads => 3,
  :on_success => :scrape,
  :proxy => {:host => 'localhost', :port => 8888},
  :head => {
    "Accept" => "*/*",
    "Keep-alive" => "true"
  }
}

multi_get ['http://www.yahoo.com/', 'http://www.google.com/', 'http://www.bing.com/'], options

puts "this happens after all callbacks."