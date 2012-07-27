# Scrapey

A simple framework for solving common scraping problems

## Installation

    $ gem install scrapey

## Create a new scrapey project

    $ scrapey my_scraper

## Examples

### Proxy switching

```ruby
def on_error e, method, url, options, *args
  host, port = @config['proxies'].sample.split(':')
  set_proxy host, port.to_i
  send method, url, options, *args
end

get 'some_throttled_website_url'
```

### Concurrent downloads

```ruby
require 'scrapey'
require 'scrapey/multi'

fields 'url', 'title'

def scrape url, response
  doc = Nokogiri::HTML response
  @items << {'url' => url, 'title' => doc.at('title').text}
end

@items = []
multi_get ['http://www.yahoo.com/', 'http://www.google.com.', 'http://www.bing.com/'], :threads => 3, :callback => :scrape
@items.each{|item| save item}
```
