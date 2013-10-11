module Scrapey

  def use_cache options = {}
    @use_cache = true
    if @redis = options.delete(:redis)
      require 'scrapey/cache/redis'
    else
      require 'scrapey/cache/disk'
      @config['cache_dir'] ||= "#{BASEDIR}/cache"
      FileUtils.mkdir_p @config['cache_dir']
    end
  end

  def disable_cache
    @use_cache = false
    yield
    @use_cache = true
  end

 
  def without_cache
    yield
  end

  def with_cache cassette_name = 'my_cassette'
    require 'vcr'
    require 'fakeweb'

    VCR.configure do |c|
      c.cassette_library_dir = "#{BASEDIR}/cache"
      c.hook_into :fakeweb
      c.allow_http_connections_when_no_cassette = true
    end

    VCR.use_cassette(cassette_name, :record => :new_episodes, :match_requests_on => [:method, :uri, :body]) do
      yield
    end
  end

end