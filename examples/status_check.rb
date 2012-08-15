require 'scrapey'
require 'scrapey/multi'
require 'pry'

fields 'url', 'status'

def on_success url, response, header
  save({'url' => url, 'status' => header.status})
end

def on_error url, e
  save({'url' => url, 'status' => e})
end

multi_head ['http://locahlost2/foo', 'http://www.google.com/', 'http://www.bing.com/', 'http://www.bing.com/404.html']
