require 'redis'

module Scrapey

  def is_cached? url
    !!@redis.get(url)
  end

  def load_cache url
    debug "Loading #{url} from cache"
    return nil unless str = @redis.get(url)
    Mechanize::Page.new(URI.parse(url), [], Marshal.load(str), nil, @agent) rescue nil
  end

  def save_cache url, body, options = {}
    @redis.set url, Marshal.dump(body)
  end
end