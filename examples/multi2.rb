require 'scrapey'
require 'scrapey/multi'
require 'pry'

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
  :proxy => {:host => 'localhost', :port => 8889, :type => :socks5},
  :head => {
    "Accept" => "*/*",
    "Keep-alive" => "true",
    "Cookie" => "foo=bar"
  }
}

multi_get ["https://twitter.com/"], options

puts "this happens after all callbacks."