# Scrapey

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'scrapey'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scrapey

## Examples

### Concurrent downloads

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

