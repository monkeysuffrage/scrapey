# Scrapey

A simple framework for solving common scraping problems

## Install latest version
### Add to Gemfile

    gem "scrapey", :git => 'https://github.com/monkeysuffrage/scrapey.git'

### Then run:
    $ bundle install

## Create a new scrapey project

    $ scrapey my_scraper

## Examples

### CSV
By default scrapey will save as 'output.csv'
You can change this with:

    @output = 'mycsv.csv'

```ruby
require 'scrapey'

page = get 'http://www.alexa.com/topsites'
page.search('li.site-listing').each do |li|
  save [li.at('a').text, li.at('.description').text, li.at('.stars')[:title]]
end
```

### Database
if you created a scrapey project you can fill out the database connection information in config/config.yml
```ruby
require 'scrapey'

tables 'Movie', 'Actor' # create ActiveRecord  models

page = get 'http://www.imdb.com/movies-in-theaters/'

page.search('div.list_item').each do |div|
  movie = Movie.find_or_create_by_title div.at('h4 a').text
  div.search('span[@itemprop="actors"] a').each do |a|
    actor = Actor.find_or_create_by_name a.text
  end
end
```

### Caching
Scrapey can cache responses so that next time they don't hit the network
```ruby
use_cache
```

You can use redis for caching if you have lots of memory
```ruby
require 'redis'
use_cache :redis => Redis.new
```

### Retries
Retry downloads on error a max of 3 times and sleep 30 seconds between retries.
```ruby
get 'some_url', :retries => 3, :sleep => 30
```
Or just handle errors in an on_error method (Scrapey will call it automatically if it's defined)
```ruby
def on_error e, method, url, options, *args
  puts "retrying #{url} again in 30 seconds..."
  sleep 30
  send method, url, options, *args
end
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
Scrapey will ensure that the callbacks are threadsafe
```ruby
require 'scrapey'

fields 'url', 'title'

def scrape url, response
  doc = Nokogiri::HTML response
  save({'url' => url, 'title' => doc.at('title').text})
end

multi_get ['http://www.yahoo.com/', 'http://www.google.com.', 'http://www.bing.com/'], :threads => 3, :on_success => :scrape
```
