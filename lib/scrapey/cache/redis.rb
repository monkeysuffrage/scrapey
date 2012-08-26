require 'redis'

module Scrapey

  def is_cached? url
    !!@redis.get(url)
  end

  def load_cache url
    debug "Loading #{url} from cache"
    return nil unless str = @redis.get(url)
    Nokogiri::HTML Marshal.load(str) rescue nil
  end

  def save_cache url, body, options = {}
    @redis.set url, Marshal.dump(body)
  end
end