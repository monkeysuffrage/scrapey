require 'scrapey'
require 'redis'
require 'pry'

@debug = true







use_cache :redis => Redis.new

url = 'http://www.yahoo.com/'
google = get url
puts google.at('title').text, (x = google.encoding rescue 'foo'), (y = google.body.encoding rescue 'foo'), '--'

google = get url
puts google.at('title').text, (x = google.encoding rescue 'foo'), (y = google.body.encoding rescue 'foo'), '--'
