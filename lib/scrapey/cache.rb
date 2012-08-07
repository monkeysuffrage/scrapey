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

end