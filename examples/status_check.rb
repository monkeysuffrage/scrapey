require 'scrapey'
require 'scrapey/multi'

fields 'url', 'status'

def on_success url, response
  save({'url' => url, 'status' => response.status_code})
end

def on_error url, e
  save({'url' => url, 'status' => e.message})
end

multi_head ['http://locahlost2/foo', 'http://www.google.com/', 'http://www.bing.com/', 'http://www.bing.com/404.html']
