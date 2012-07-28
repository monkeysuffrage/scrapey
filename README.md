# Scrapey

A simple framework for solving common scraping problems

## Installation

    $ gem install scrapey

## Create a new scrapey project

    $ scrapey my_scraper

## Examples

### CSV

```ruby
require 'scrapey'
# By default scrapey will save as 'output.csv'
# You can change this with:
# @output = 'mycsv.csv'

page = get 'http://www.alexa.com/topsites'
page.search('li.site-listing').each do |li|
  save [li.at('a').text, li.at('.description').text, li.at('.stars')[:title]]
end
```

### Database
```ruby
require 'scrapey'
# if you created a scrapey project you can fill out the database connection
# information in config/config.yml

tables 'Movie', 'Actor' # create ActiveRecord  models

page = get 'http://www.imdb.com/movies-in-theaters/'

page.search('div.list_item').each do |div|
  movie = Movie.find_or_create_by_title div.at('h4 a').text
  div.search('span[@itemprop="actors"] a').each do |a|
    actor = Actor.find_or_create_by_name a.text
  end
end
```

### Retries
```ruby
# retry downloads on error a max of 3 times and sleep 30 seconds between retries.
get 'some_url', :retries => 3, :sleep => 30
```

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
