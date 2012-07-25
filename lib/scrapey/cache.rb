module Scrapey
  def use_cache
    @use_cache = true
    @config['cache_dir'] ||= "#{BASEDIR}/cache"
    FileUtils.mkdir_p @config['cache_dir']
  end

  def cache_filename url
    @config['cache_dir'] + "/" + Digest::MD5.hexdigest(url) + ".cache"
  end

  def load_cache url
    filename = cache_filename url
    return nil unless File::exists?(filename)
    puts "Loading #{filename} from cache"
    Nokogiri::HTML File.read(filename)
  end

  def save_cache url,doc
    File.open(cache_filename(url), 'wb') {|f| f.write(doc) }
  end
end