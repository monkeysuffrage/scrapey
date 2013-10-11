require 'scrapey'

fields 'url', 'title'

def scrape url, response, header
  doc = Nokogiri::HTML response
  save({'url' => url, 'title' => doc.title})
  puts "scraped #{url}."
end

options = {
  :threads => 3,
  :on_success => :scrape,
  :proxy => 'http://localhost:8888',
  :headers => {
    "Accept" => "*/*",
    "Keep-alive" => "true",
    "Cookie" => "foo=bar"
  }
}

multi_get ["https://twitter.com/", 'http://www.yahoo.com/', 'http://www.google.com.', 'http://www.bing.com/'], options

puts "this happens after all callbacks."